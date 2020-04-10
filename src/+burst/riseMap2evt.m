function [evtMap,evtMemC,evtMemCMap] = riseMap2evt(spLst,dlyMap,distMat,maxRiseUnc,cDelay,stg)

nSp = numel(spLst);
[H,W] = size(dlyMap);
evtMap = zeros(H,W);
if(nSp==0)
    evtMemC = [];
    evtMemCMap = [];
   return; 
end

% distMatIn = distMat;
distMat = abs(distMat);

spMap = zeros(H,W);
riseX = nan(nSp,1);
for nn=1:nSp
    spMap(spLst{nn}) = nn;
    riseX(nn) = mean(dlyMap(spLst{nn}));
end

% get local minimum as event starting point
% small area starting point not trustable
% initAreaThr = max(sum(spMap(:)>0)/50/10,30);
initAreaThr = 30;
dlyMap1 = dlyMap;
mskDly = ~isinf(dlyMap1);
for ii=1:1000
    lm = imregionalmin(round(dlyMap1*100));
    lm = lm.*mskDly;
    %zzshow(lm);
    if max(lm(:))==0
        lm = mskDly;
    end
    cc = bwconncomp(lm);
    allOK = 1;
    for jj=1:cc.NumObjects
        pix0 = cc.PixelIdxList{jj};
        if numel(pix0)<initAreaThr
            sp00 = spMap(pix0);
            sp00 = unique(sp00);
            sp00 = sp00(sp00>0);
            if sum(sp00==476)>0
                %keyboard
            end
            xNeib = [];
            for kk=1:numel(sp00)
                neib0 = find(~isnan(distMat(sp00(kk),:)));
                xNeib = union(neib0,xNeib);
            end
            xNeib = setdiff(xNeib,sp00);
            if ~isempty(xNeib)
                allOK = 0;
                tNew = min(riseX(xNeib));
                dlyMap1(pix0) = tNew;
            end
        end
    end
    if allOK==1
        break
    end
end

% seeds in current local minimum
seedLm = [];
for ii=1:cc.NumObjects
    pix0 = cc.PixelIdxList{ii};
    sp00 = spMap(pix0);
    sp00 = sp00(sp00>0);
    sp00 = unique(sp00);
    [~,ix] = min(riseX(sp00));
    seedLm = union(seedLm,sp00(ix));
end

% remove weak local maximum
% check whether a seed is valid
% start searching from earliest one
[~,seedOrd] = sort(riseX(seedLm),'descend');
lmSel = zeros(numel(seedLm),1);
seedLm1 = seedLm;
nSeed = 1;
for ii=1:numel(seedLm)
    if mod(ii,10)==0; fprintf('%d\n',ii); end
    idxCenter = seedLm(seedOrd(ii));
    
    riseCenter = riseX(idxCenter);
    idxMemCand = find(riseX<=riseCenter+maxRiseUnc);
    distMat0 = distMat(idxMemCand,idxMemCand);
    distMat0(~isnan(distMat0)) = 1;
    distMat0(isnan(distMat0)) = 0;
    distMat0(eye(size(distMat0,1))>0) = 1;
    G = digraph(distMat0);
    s0 = find(idxMemCand==idxCenter);
    d0 = distances(G,s0);
    idxMem = idxMemCand(d0<Inf);
    if numel(intersect(idxMem,seedLm1))==1
        lmSel(seedOrd(ii)) = nSeed;
        nSeed = nSeed + 1;
    end
    seedLm1(seedOrd(ii)) = nan;
end

if 0
    lmSelMap = zeros(H,W);
    lmMap = zeros(H,W);
    for nn=1:numel(lmSel)
        lmMap(spLst{seedLm(nn)}) = seedLm(nn);
        if lmSel(nn)>0
            lmSelMap(spLst{seedLm(nn)}) = seedLm(nn);
        end
    end
    tmp = dlyMap; tmp(isinf(tmp)) = nan;
    tmp = nanmax(tmp(:))-tmp;
    tmp = tmp/nanmax(tmp(:));
    tmp1 = cat(3,lmMap,tmp,tmp*0); zzshow(tmp1);
    tmp1 = cat(3,lmSelMap,tmp,tmp*0); zzshow(tmp1);
end

% the event each seed belongs to
spEvt = zeros(nSp,1);
for ii=1:numel(seedLm)
    spEvt(seedLm(ii)) = lmSel(ii);
end

evtMemCMap = zeros(H,W);
if stg==1
    spEvt = burst.evtGrowLm(spEvt,distMat,riseX,spMap);
else
    % grow seed, find continuous regions
    [evtMem,evtMemC] = burst.evtGrowLm1(spEvt,distMat,cDelay,spMap);
    spEvt = evtMem;
    
%     % find direction in each continuous region
%     for ii=1:max(evtMemC(:))
%         idx0 = evtMemC==ii;
%         spEvt0 = spEvt(idx0);
%         distMat0 = distMat(idx0,idx0);
%         riseX0 = riseX(idx0);
%         spEvt0 = burst.evtGrowLm(spEvt0,distMat0,riseX0,spMap);
%         spEvt(idx0) = spEvt0;
%     end
%     
%     plt.superPixelsSelected(spMap,evtMem);
%     plt.superPixelsSelected(spMap,evtMemC);
%     plt.superPixelsSelected(spMap,spEvt);
%     keyboard
%     close all
    
    for ii=1:numel(evtMemC)
        evtMemCMap(spLst{ii}) = evtMemC(ii);
    end
end

% gather events
pixLst = label2idx(spMap);
evt0 = unique(spEvt);
evt0 = evt0(evt0>0);
nEvt0 = numel(evt0);
for ii=1:nEvt0
    pix0 = pixLst(spEvt==evt0(ii));
    for jj=1:numel(pix0)
        pix00 = pix0{jj};
        evtMap(pix00) = ii;
    end
end

end




