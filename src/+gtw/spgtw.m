function [spLst,cx,dlyMap,distMat,rgt00,isFail,evtMemC,evtMemCMap] = spgtw(...
    dF,seMap,seSel,smoBase,maxStp,cDelay,spSz,spT,opts)
% spgtw super pixel GTW 
% make one burst to super pixels and run gtw

if ~isfield(opts,'gtwGapSeedMin') || ~isfield(opts,'gtwGapSeedRatio')
    opts.gtwGapSeedRatio = 4;
    opts.gtwGapSeedMin = 5;
end

[H,W,T] = size(dF);
isFail = 0;
maxStp = max(min(maxStp,round(T/2)),1);

% dF and local noise
dFDif = (dF(:,:,1:end-1)-dF(:,:,2:end)).^2;
s00 = double(sqrt(median(dFDif(:))/0.9113));

%% super pixels
% extract one event
validMap = sum(seMap==seSel,3)>0;

dFip = dF;
% s00 = sqrt(opts.varEst);

pk = nanmedian(dF(seMap==seSel)/s00);
thrpk = 0.5*pk;

dFip(seMap>0 & seMap~=seSel) = nan;
dFip(dF>thrpk*s00 & seMap~=seSel) = nan;
dFip = gtw.imputeMov(dFip);

dFmax = max(movmean(dFip,5,3),[],3);
dFmax(dFmax<0) = 0;
dFInfo = medfilt2(dFmax);  % information in each pixel, for peak SNR
dFInfo(isnan(dFInfo)) = 0;

% rising time as feature
thrMax = ceil(quantile(dFip(:),0.999)/s00);
thrVec = 0:thrMax;
m0Msk = zeros(H,W,T); m0Msk(seMap==seSel)=1; m0Msk(seMap>0 & seMap~=seSel) = -1;
tMapMT = burst.getSuperEventRisingMapMultiThr(dFip,m0Msk,thrVec,s00);
tMapMTValid = sum(~isnan(tMapMT),3)>0;
validMap = validMap & tMapMTValid;

% signal part
idx0 = find(m0Msk>0);
[~,~,it0] = ind2sub(size(m0Msk),idx0);
rgt00 = max(min(it0)-5,1):min(max(it0)+5,T);
dat = double(dFip(:,:,rgt00));

% region growing
nPixTot = sum(validMap(:)>0);
nSpMax = round(10000*spT/(max(it0)-min(it0)+1));
nSpTgt = ceil(nPixTot/spSz);
if nSpTgt>nSpMax/2
    nSpTgt = nSpMax/2;
end

dFVec = reshape(dFip,[],T);
mAvg = nanmean(dFVec(validMap>0,:));
snrInit = ceil(max(mAvg)/(s00/sqrt(spSz)));
snrThr = snrInit;
tb = nan(10,2);
for ii=1:5
% for ii=1:numel(snrVec)
    %snrThr = snrVec(ii);
    gaphw = (11-ii)*5+5;
    [spLst,spSeedVec,spSz,~,spStd] = gtw.mov2spSNR(dF,dFInfo,tMapMT,validMap,snrThr,gaphw);
    fprintf('Max %d - Tgt %d - Now %d - Thr %f\n',nSpMax,nSpTgt,numel(spLst),snrThr)
    
    tb(ii,1) = snrThr;
    tb(ii,2) = numel(spLst);
    %if numel(spLst)<=nSpMax && numel(spLst)>=nSpTgt
    if numel(spLst)<=nSpMax
        break
    end    
    dif0 = tb(:,2)-nSpMax;  % too many
    dif0(dif0<0) = nan;
    [x0,ix0] = nanmin(dif0);
    dif1 = nSpTgt-tb(:,2);  % not enough
    dif1(dif1<0) = nan;
    [x1,ix1] = nanmin(dif1);    
    
    % binary search
    if isnan(x0)  % all not enough
        snrThr = tb(ix1,1)/1.5;
    elseif isnan(x1)  % all too many
        snrThr = tb(ix0,1)*1.5;
    else
        snrThr = (tb(ix1,1)+tb(ix0,1))/2;
    end
end

if numel(spLst)<2
    spLst = {find(validMap>0)};
    cx = [];
    dlyMap = [];
    distMat = [];
    evtMemC = [];
    evtMemCMap = [];
    rgt00 = 1:T;
    isFail = 1;
    return
end
fprintf('Node %d, SNR %d dB Ratio %.2f\n',numel(spLst),20*log10(snrThr),sum(spSz)/nPixTot)

%% alignment
% graph
[ih0,iw0] = find(validMap>0);
gapSeed = max(ceil(max(max(ih0)-min(ih0),max(iw0)-min(iw0))/opts.gtwGapSeedRatio),opts.gtwGapSeedMin);
[ref,tst,refBase,s,t,idxGood] = gtw.sp2graph(dat,validMap,spLst,spSeedVec(1),gapSeed);

% gtw
spLst = spLst(idxGood);
spSeedVec = spSeedVec(idxGood);
s2 = spStd(idxGood).^2;
s2(s2==0) = median(s2);
if numel(spLst)>3 && numel(refBase)>5
    tic
    [ ss,ee,gInfo ] = gtw.buildGTWGraph( ref, tst, s, t, smoBase, maxStp, s2);
    [~, labels1] = aoIBFS.graphCutMex(ss,ee);
    path0 = gtw.label2path4Aosokin( labels1, ee, ss, gInfo );
    t00 = toc;
    if numel(spLst)>1000
        fprintf('Time %fs\n',t00);
    end
else
    [nPix,nTps] = size(tst);
    path0 = cell(nPix,1);
    rg = (0:nTps)';
    p0 = [rg,rg,rg+1,rg+1];
    for ii=1:nPix
        path0{ii} = p0;
    end
end

% warped curves
pathCell = cell(H,W);
vMap1 = zeros(H,W);
vMap1(spSeedVec) = 1:numel(spSeedVec);
for ii=1:numel(spLst)
    [ih0,iw0] = ind2sub([H,W],spSeedVec(ii));
    pathCell{ih0,iw0} = path0{ii};
end
datWarp = gtw.warpRef2Tst(pathCell,refBase/max(refBase(:)),vMap1,[H,W,numel(refBase)]);
dVec = reshape(datWarp,[],numel(refBase));
cx = dVec(spSeedVec,:);

% time to achieve different levels for each seed
nSp = numel(spLst);
thrVec = 0.5:0.05:0.95;
tAch = nan(nSp,numel(thrVec));
for nn=1:nSp
    x = cx(nn,:);
    [~,t0] = max(x);
    x = x(1:t0);
    for ii=1:numel(thrVec)
        t1 = find(x>=thrVec(ii),1);
        if isempty(t1)
            t1 = t0;
        end
        tAch(nn,ii) = t1;
    end
end
tDly = mean(tAch,2);

% direction for each pair
nPair = numel(s);
distMat = nan(nSp,nSp);
% cDelay = 1e8;  % !!
for nn=1:nPair
    s0 = s(nn);
    t0 = t(nn);
    d0 = tAch(s0,:)-tAch(t0,:);  % negative is earlier
    d0 = sum(d0)/numel(thrVec);
    %d0a = abs(d0)-cDelay;
    %d0a(d0a<0) = 0;
    %if sum(d0a)==0
    distMat(s0,t0) = d0;
    distMat(t0,s0) = -d0;
    %end
end

% delay map
dlyMap = inf(H,W);
for nn=1:numel(spLst)
    dlyMap(spLst{nn}) = tDly(nn);
end

% partition by continuity
A = Inf(nSp,nSp);
[ia,ib] = find(~isnan(distMat));
for ii=1:numel(ia)
    ia0 = ia(ii);
    ib0 = ib(ii);
    A(ia0,ib0) = min(abs(distMat(ia0,ib0)),A(ia0,ib0));
end
A(A>cDelay) = Inf;

B = A;
B(A<inf) = 1;
B(isinf(A)) = 0;
B(eye(nSp)>0) = 1;
B = max(B,B');

G = graph(B);
evtMemC = zeros(nSp,1);
cc = conncomp(G,'OutputForm','cell');
for ii=1:numel(cc)
    cc0 = cc{ii};
    evtMemC(cc0) = ii;
end

evtMemCMap = zeros(H,W);
for ii=1:numel(evtMemC)
    evtMemCMap(spLst{ii}) = evtMemC(ii);
end

end







