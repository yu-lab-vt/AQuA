function [ ss,ee,gInfo ] = buildGTWGraph( ref, tst, s, t, smoBase, winSize, s2)
%buildGraph4Aosokin Build the dual graph of dynamic time warping problem
% For Aosokin's Matlab wrappers, like https://github.com/aosokin/graphCutMex_IBFS
%
% Consider graph constraint information and windowing
% Use coordinate to specify nodes in template pair, but use integer for spatial
% Support arbitrary graph
%
% ref: 1xT or NxT reference curve
% tst: NxT curves for pixels
% s,t: graph edge pair, undirected, if has pair (i,j), do not include (j,i), do not use (i,i) 
%
% smoBase: smoothness between edges
% winSize: window size, (winSize-1) lines above and below diagonal
% s2: noise variance for each test curve, or use single s2 for all test curves
%
% Basic constraint:
% No skipping/turn left/go down: otherwise has infinite cost (capacity)
% Start NEAR (1,1) and stop NEAR (T,T)
%
% ALL INPUTS SHOULD BE DOUBLE
%
% Yizhi Wang, CBIL@VT
% freemanwyz@gmail.com
% Apr.12, 2018

[nNode,T] = size(tst);
winSize = max(min(winSize,T-1),1);
% winSize = max(min(winSize,round(T/2)),1);

capRev = 1e8;
pmCost = (0:winSize)*1e8;

if numel(s2)==1
    s2 = zeros(nNode,1)+s2;
end
nEdge = numel(s);

%% template using coordinate
[pEdge, dEdge, weightPos, weightVal, st01, ~] = gtw.buildPairTemplate(T,winSize,pmCost,0);

% direction penalty, additive or multiplicative
weightValMul = weightVal*0+1;

% re-code coordinates to single number
tmp = dEdge*4;
scl0 = 1e8;  % larger than time points
tmp = [tmp(:,1)*scl0 + tmp(:,2),tmp(:,3)*scl0 + tmp(:,4)];
[tmpUniq, ia] = unique(tmp);

nNodeGrid = length(tmpUniq)-2;  % number of nodes in each pair
srcNode = nNodeGrid*nNode + 1;  % id for source node
sinkNode = nNodeGrid*nNode + 2;  % id for sink node

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
wtPos1 = sub2ind([T,T+1],weightPos(:,1),weightPos(:,2));
ssTmpPos = zeros(nNodeGrid,2) + T*T + 1;
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
ssPair = zeros(nNode*nNodeGrid,2);
eePair = zeros(nNode*nEdgeGrid,4);
eePair(:,4) = capRev;
for ii=1:nNode
    s2x = s2(ii);
    idxPix = ii;
    eeOfst = (idxPix-1)*nEdgeGrid;
    ssOfst = (idxPix-1)*nNodeGrid;
    
    % position (1,T+1) means not using distance matrix
    if size(ref,1)==1
        d0 = gtw.getDistMat(ref,tst(idxPix,:))/s2x;
    else
        d0 = gtw.getDistMat(ref(idxPix,:),tst(idxPix,:))/s2x;
    end
    d0ext = [d0,zeros(size(d0,1),1)];
    
    % edges from src and to sink
    ssPair(ssOfst+1:ssOfst+nNodeGrid,:) = reshape(d0ext(ssTmpPos(:)) + ssTmpWt(:),[],2);
    
    % edges between nodes
    tmp = [eeTmp(:,1:2) + ssOfst, (d0ext(eeTmp(:,3))+eeTmp(:,4)).*eeTmp(:,5)];
    eePair(eeOfst+1:eeOfst+nEdgeGrid,1:3) = tmp;
end


%% edges for between pairs
eeSpa = zeros(nNodeGrid*nEdge,4);
nn = 0;
for ii=1:nEdge
    nowIdx = s(ii);
    tgtIdx = t(ii);
    idx1 = nn+1;
    idx2 = nn+nNodeGrid;
    eeSpa(idx1:idx2,1) = (nowIdx-1)*nNodeGrid + (1:nNodeGrid);
    eeSpa(idx1:idx2,2) = (tgtIdx-1)*nNodeGrid + (1:nNodeGrid);
    eeSpa(idx1:idx2,3:4) = smoBase;
    nn = nn + nNodeGrid;    
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

gInfo.srcSinkPos = st01;
gInfo.T = T;
gInfo.nPix = nNode;
gInfo.nNodeGrid = nNodeGrid;
gInfo.nNodes = nNodeGrid*nNode+2;
gInfo.nEdgeGrid = nEdgeGrid;









