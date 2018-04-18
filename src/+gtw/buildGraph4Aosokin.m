function [ ss,ee,gInfo ] = buildGraph4Aosokin( ref, tst, validMap, param)
%buildGraph4Aosokin Build the dual graph of dynamic time warping problem
% For Aosokin's Matlab wrappers, like https://github.com/aosokin/graphCutMex_IBFS
%
% Consider LOCAL spatial information, windowing and subsequent matching
% Use coordinate to specify nodes in template pair, but use integer for spatial
% Fully using coordinate seems to be slow in building graph
% Support both single pair and spatial
% Support flexible pixel based smoothness selection
%
% ref: 1xT or NxT reference curve
% tst: NxT curves for pixels
% validMap: active region used, HxW
% capSpatial: single spaital cost
% %capSpatial: (H-1)x(W-1)xTx2, difference with east and north pixel pairs
% winSize: window size, (winSize-1) lines above and below diagonal
% offsetPenalty: force the path to be near the diagonal line
%
% Basic constraint:
% No skipping/turn left/go down: otherwise has infinite cost (capacity)
% Start NEAR (1,1) and stop NEAR (T,T)
%
% Todo:
% Edge based smoothness constraints
%
% Yizhi Wang, CBIL@VT
% freemanwyz@gmail.com

smoMap = param.smoMap;
smoBase = param.smoBase;
s2 = param.s2;
win = param.winSize;
capRev = 1e8;
ofstPen = param.offDiagonalPenalty;
pmCost = param.partialMatchingCost;
bds = param.bds;
bdsCell = param.bdsCell;
sclxx = param.smox;

[H,W] = size(validMap);
dh = [0,-1,1,0];
dw = [-1,0,0,1];

%% setup
[nPix,nTps] = size(tst);

distMask = zeros(nTps,nTps);
for ii=1:nTps
    for jj=1:nTps
        distMask(ii,jj) = ofstPen*(abs(ii-jj)>0);
    end
end

scl0 = 1e8;  % larger than time points
validMapIdx = validMap*0;
validMapIdx(validMap>0) = 1:sum(validMap(:)>0);

nNeibPair = 0;
for jj=1:W
    for ii=1:H
        if validMap(ii,jj)==1
            if jj+1<=W && validMap(ii,jj+1)==1
                nNeibPair = nNeibPair + 1;
            end
            if ii+1<=H && validMap(ii+1,jj)==1
                nNeibPair = nNeibPair + 1;
            end
        end
    end
end

if numel(s2)==1
    tmp = validMap;
    tmp(validMap>0) = s2;
    s2 = tmp;
end
s2x = s2(s2>0);
s2xMean = nanmean(s2x(:));
pmCost = pmCost/2/s2xMean;

%% template using coordinate
[pEdge, dEdge, weightPos, weightVal, st01, ~] = gtw.buildPairTemplate(nTps,win,pmCost,0);

% direction penalty, additive or multiplicative
% weightVal(eType==2) = weightVal(eType==2);
weightValMul = weightVal*0+1;
% weightValMul(eType==2) = 1;

% re-code coordinates to single number
tmp = dEdge*4;
tmp = [tmp(:,1)*scl0 + tmp(:,2),tmp(:,3)*scl0 + tmp(:,4)];
[tmpUniq, ia] = unique(tmp);

nNodeGrid = length(tmpUniq)-2;  % number of nodes in each pair
srcNode = nNodeGrid*nPix + 1;  % id for source node
sinkNode = nNodeGrid*nPix + 2;  % id for sink node

mapObj = containers.Map(tmpUniq,[sinkNode,1:nNodeGrid,srcNode]);
dEdgeInt = cell2mat(values(mapObj,num2cell(tmp)));

dEdge1 = [dEdge(:,1:2);dEdge(:,3:4)];
nodePos = dEdge1(ia(2:end-1),:);


%% split the edge matrix to src/sink and within grid
% nodes connected with src or sink
d1 = dEdgeInt(:,1);
d2 = dEdgeInt(:,2);
idxSrc = find(d1==srcNode);
idxSink = find(d2==sinkNode);

% extra weight for ss edges
ssTmpWt = zeros(nNodeGrid,2);
ssTmpWt(d2(idxSrc),1) = weightVal(idxSrc);
ssTmpWt(d1(idxSink),2) = weightVal(idxSink);

% weight from curve distance for ss edges
wtPos1 = sub2ind([nTps,nTps+1],weightPos(:,1),weightPos(:,2));
ssTmpPos = zeros(nNodeGrid,2) + nTps*nTps + 1;
ssTmpPos(d2(idxSrc),1) = wtPos1(idxSrc);
ssTmpPos(d1(idxSink),2) = wtPos1(idxSink);

% edges between nodes (except src and sink)
idxNotSS = d1~=srcNode & d2~=sinkNode;
eeTmp = [dEdgeInt(idxNotSS,:),wtPos1(idxNotSS),weightVal(idxNotSS),weightValMul(idxNotSS)];
nEdgeGrid = size(eeTmp,1);

% output, for label and path mapping
pEdgeSS = pEdge(~idxNotSS,:);
pEdgeEE = pEdge(idxNotSS,:);
dEdgeIntSS = dEdgeInt(~idxNotSS,:);
dEdgeIntEE = dEdgeInt(idxNotSS,:);


%% edges for within pairs, using integer code
ssPair = zeros(nPix*nNodeGrid,2);
eePair = zeros(nPix*nEdgeGrid,4);
eePair(:,4) = capRev;
for jj=1:W
    for ii=1:H
        if validMap(ii,jj)==1
            s2x = s2(ii,jj);
            
            idxPix = validMapIdx(ii,jj);
            eeOfst = (idxPix-1)*nEdgeGrid;
            ssOfst = (idxPix-1)*nNodeGrid;
            
            % position (1,T+1) means not using distance matrix
            if size(ref,1)==1
                d0 = gtw.getDistMat(ref,tst(idxPix,:))/s2x + distMask;
            else
                d0 = gtw.getDistMat(ref(idxPix,:),tst(idxPix,:))/s2x + distMask;
            end
            d0ext = [d0,zeros(size(d0,1),1)];
            
            % edges from src and to sink
            ssPair(ssOfst+1:ssOfst+nNodeGrid,:) = reshape(d0ext(ssTmpPos(:)) + ssTmpWt(:),[],2);
            
            % add cost from boundary constraints for border pixels
            if ~isempty(bds)
                if bds(ii,jj)>0
                    for dd=1:length(dh)
                        dh0 = ii+dh(dd);
                        dw0 = jj+dw(dd);
                        
                        % if a neighbor is also a border pixel
                        if dh0>0 && dh0<=H && dw0>0 && dw0<=W
                            if bds(dh0,dw0)>0
                                lbl0 = bdsCell{dh0,dw0};
                                if ~isempty(lbl0)
                                    smo0 = smoMap(ii,jj,1)*1;
                                    ssCost0 = zeros(nNodeGrid,2);
                                    ssCost0(lbl0==0,1) = smo0;  % 0,1
                                    ssCost0(lbl0==1,2) = smo0;  % 1,2
                                    ssPair(ssOfst+1:ssOfst+nNodeGrid,:) = ssPair(ssOfst+1:ssOfst+nNodeGrid,:) + ssCost0;
                                end
                            end
                        end
                    end
                end             
            end                       
            
            % edges between nodes
            %tmp = [eeTmp(:,1:2) + ssOfst, (d0ext(eeTmp(:,3))+eeTmp(:,4)).*eeTmp(:,5)];
            tmp = [eeTmp(:,1:2) + ssOfst, (d0ext(eeTmp(:,3))+eeTmp(:,4)).*eeTmp(:,5)];
            ee1 = tmp(:,1); ee2 = tmp(:,2); 
            if sum(ee1==ee2)>0
                keyboard
            end
            eePair(eeOfst+1:eeOfst+nEdgeGrid,1:3) = tmp;
        end
    end
end

%% edges for between pairs
eeSpa = zeros(nNodeGrid*nNeibPair,4);
% eeSpa(:,3:4) = smo;
nn = 0;
for jj=1:W
    for ii=1:H
        if validMap(ii,jj)==1
            nowIdx = validMapIdx(ii,jj);
            if jj+1<=W && validMap(ii,jj+1)==1  % east direction
                idx1 = nn+1;
                idx2 = nn+nNodeGrid;
                tgtIdx = validMapIdx(ii,jj+1);
                eeSpa(idx1:idx2,1) = (nowIdx-1)*nNodeGrid + (1:nNodeGrid);
                eeSpa(idx1:idx2,2) = (tgtIdx-1)*nNodeGrid + (1:nNodeGrid);
                smo0 = smoMap(ii,jj,1);
                %smo0 = min(smoMap(ii,jj),smoMap(ii,jj+1));
                eeSpa(idx1:idx2,3:4) = smo0*sclxx;
                nn = nn + nNodeGrid;
            end
            if ii+1<=H && validMap(ii+1,jj)==1  % south direction
                idx1 = nn+1;
                idx2 = nn+nNodeGrid;
                tgtIdx = validMapIdx(ii+1,jj);
                eeSpa(idx1:idx2,1) = (nowIdx-1)*nNodeGrid + (1:nNodeGrid);
                eeSpa(idx1:idx2,2) = (tgtIdx-1)*nNodeGrid + (1:nNodeGrid);
                smo0 = smoMap(ii,jj,2);
                %smo0 = min(smoMap(ii,jj),smoMap(ii+1,jj));
                eeSpa(idx1:idx2,3:4) = smo0*sclxx;
                nn = nn + nNodeGrid;
            end
        end
    end
end

ss = ssPair;
if smoBase>0
    ee = [eePair;eeSpa];
else
    ee = eePair;
end


%% output
gInfo = [];

gInfo.nodePos = nodePos;
gInfo.weightPos = weightPos;
gInfo.weightVal = weightVal;

gInfo.pEdge = pEdge;
gInfo.pEdgeSS = pEdgeSS;
gInfo.pEdgeEE = pEdgeEE;

gInfo.dEdge = dEdge;
gInfo.dEdgeInt = dEdgeInt;
gInfo.dEdgeIntSS = dEdgeIntSS;
gInfo.dEdgeIntEE = dEdgeIntEE;

gInfo.validMap = validMap;
gInfo.srcSinkPos = st01;
gInfo.T = nTps;
gInfo.nPix = nPix;
gInfo.nNodeGrid = nNodeGrid;
gInfo.nNodes = nNodeGrid*nPix+2;
gInfo.nEdgeGrid = nEdgeGrid;









