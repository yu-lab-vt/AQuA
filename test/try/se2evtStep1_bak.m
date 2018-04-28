%% normalize data to super pixels containing simialr information about phase
% rr: dat, c1x

f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001_Substack (1401-1500)';
rr = load(['D:\neuro_WORK\glia_kira\tmp\superevents\',f0,'.mat']);

% dat = rr.dat.^2;
dat = rr.dat;
c1x = rr.c1x;

[H,W,T] = size(rr.dat);

datMA = movmean(dat,ceil(T/5),3);
datBase = min(datMA,[],3);
dF = dat - datBase;
dFDif = (dF(:,:,1:end-1) - dF(:,:,2:end)).^2;
s00 = double(sqrt(median(dFDif(:))/0.9113));

% sMap = sqrt(median(dFDif,3)/0.9113);
% zzshow(sMap*10)

seMap = zeros(H,W,T);
for nn=1:numel(c1x)
    seMap(c1x{nn}) = nn;
end

%% extract one event
[~,seSel] = nanmax(cellfun(@numel,c1x));
m0s = sum(seMap==seSel,3)>0;
nPixValid = sum(m0s(:)>0);

dFip = dF;
dFip(seMap>0 & seMap~=seSel) = nan;
dFip = gtw.imputeMov(dFip);

% null information
% dSim = randn(size(dFip))*s00;  % bias estimation
% dSimMax = max(movmean(dSim,5,3),[],3);
dFmax = max(movmean(dFip,5,3),[],3);
% dFmax = dFmax - median(dSimMax(:));
dFmax(dFmax<0) = 0;
figure;imagesc(dFmax);
set(gca,'Position',[0 0 1 1],'DataAspectRatio',[H W 1]);
dFInfo = medfilt2(dFmax);  % information in each pixel, for peak SNR
dFInfo(isnan(dFInfo)) = 0;
figure;imagesc(dFInfo);
set(gca,'Position',[0 0 1 1],'DataAspectRatio',[H W 1]);

% rising time as feature
thrMax = ceil(quantile(dFip(:),0.999)/s00);
thrVec = 1:thrMax;
dFx = dFip;
m0Msk = zeros(H,W,T); m0Msk(seMap==seSel)=1; m0Msk(seMap>0 & seMap~=seSel) = -1;
tMapMT = burst.getSuperEventRisingMapMultiThr(dFx,m0Msk,thrVec,s00);
tMapMTValid = sum(~isnan(tMapMT),3)>0;
m0s = m0s & tMapMTValid;

% for ii=1:numel(thrVec)
%     x00 = tMapMT(:,:,ii);
%     figure;imagesc(x00,'AlphaData',~isnan(x00));colorbar;pause(0.1)
% end


%% region growing
% nSizeRough = 25;
% infoTot = sum(dFInfo(m0s));
% [~,~,it0] = find(m0Msk>0);
% Tx = max(it0)-min(it0)+10;
% nSpTgt = min(100*100*30/Tx,round(nPixValid/nSizeRough));
% infoSp = infoTot/nSpTgt;

snrThr = 10;
gaphw = 10;

xSim = movmean(randn(10000,T),5,2);
xMax = max(xSim,[],2);
xMaxBias = mean(xMax);

availMap = m0s>0;
[dIx,dIix] = sort(dFInfo(:),'descend');
mapx = zeros(H,W);
mapx(dIix) = 1:H*W;
dIx(mapx(availMap==0)) = 0;
% availMapx = true(H,W);
availMapx = availMap;
nSp = 1;
spLst = cell(0);
spSeedVec = zeros(0);
for nn=1:numel(dIx)
    if dIx(nn)==0
        continue
    end
    iSeedIn = dIix(nn);    
    
    % extract region
    [ihSeed,iwSeed] = ind2sub([H,W],iSeedIn);
    rgh = max(ihSeed-gaphw,1):min(ihSeed+gaphw,H);
    rgw = max(iwSeed-gaphw,1):min(iwSeed+gaphw,W);
    H1 = numel(rgh);
    W1 = numel(rgw);
    ihSeed = ihSeed-min(rgh)+1;
    iwSeed = iwSeed-min(rgw)+1;
    iSeed = sub2ind([H1,W1],ihSeed,iwSeed);
    
    df0 = dF(rgh,rgw,:);
    df0Vec = reshape(df0,[],T);
    
    %dI0 = dFInfo(rgh,rgw);
    %xInfo = dI0(ihSeed,iwSeed);
    ft = tMapMT(rgh,rgw,:);
    availMap0 = availMapx(rgh,rgw);
    availMap0(ihSeed,iwSeed) = false;
    
    % distances: delay, intensity and distance
    ftBase = reshape(ft(ihSeed,iwSeed,:),1,[]);
    if sum(~isnan(ftBase))==0
        continue
    end
    ftVec = reshape(ft,[],size(ft,3));
    distDelay = nanmedian(abs(ftVec - ftBase),2);
    distDelay(isnan(distDelay)) = Inf;
    distInt = abs(sum(isnan(ftVec),2)-sum(isnan(ftBase)));
    [ih1,iw1] = find(ones(H1,W1));
    distEuc = sqrt((ihSeed-ih1).^2+(iwSeed-iw1).^2);
    distx = distDelay+distInt*0.5+distEuc*2;
    %distx = distEuc+distInt*0.5;
    distx = reshape(distx,H1,W1);
    %figure;imagesc(distx,'AlphaData',~isinf(distx));colorbar
    
    % region growing
    neibSet = [];
    newPix = iSeed;    
    pixSet =iSeed;
    for ii=1:100
        % SNR
        xm = mean(df0Vec(pixSet,:),1);
        sNow = sqrt(median((xm(2:end)-xm(1:end-1)).^2)/0.9113);        
        xm = movmean(xm,5);
        xMax = max(xm) - xMaxBias*sNow;
        snrNow = xMax/sNow;
        if snrNow>=snrThr  % enough information
            break
        end
        
        [ih2,iw2] = ind2sub([H1,W1],newPix);
        h00 = [min(ih2+1,H1),max(ih2-1,1),ih2,ih2];
        w00 = [iw2,iw2,max(iw2-1,1),min(iw2+1,W1)];
        newCand = unique(sub2ind([H1,W1],h00,w00));
        newCand = newCand(availMap0(newCand));
        neibSet = union(neibSet,newCand);
        if isempty(neibSet)  % no new neighbors
            break
        end
        neibDist = distx(neibSet);
        [x,ix] = min(neibDist);
        if isinf(x)  % no valid neighbor
            break
        end
        newPix = neibSet(ix);
        availMap0(newPix) = false;
        pixSet = union(pixSet,newPix);
        neibSet = setdiff(neibSet,newPix);
        %xInfo = xInfo+dI0(newPix);
    end
    
    availMapx(rgh,rgw) = availMapx(rgh,rgw).*availMap0;
    [ihx,iwx] = ind2sub([H1,W1],pixSet);
    spLst0 = sub2ind([H,W],ihx+min(rgh)-1,iwx+min(rgw)-1);
    dIx(mapx(spLst0)) = 0;
    %pixMap = zeros(H1,W1); pixMap(pixSet) = 1; zzshow(pixMap)

    if snrNow<snrThr
        continue
    end
    spSeedVec(nSp) = iSeedIn;
    spLst{nSp} = spLst0;    
    %ov0 = plt.regionMapWithData(spLst,zeros(H0,W0),0.5); zzshow(ov0);
    nSp = nSp+1;
    if mod(nSp,1000)==0
        fprintf('%d\n',nSp)
        %break
    end
end

%% plot
spMap = zeros(H,W);
spCenterMap = zeros(H,W);
for nn=1:numel(spLst)
    sp0 = spLst{nn};
    if ~isempty(sp0)
        spMap(spLst{nn}) = nn;
    end
    [h0,w0] = ind2sub([H,W],sp0);
    spCenterMap(round(mean(h0)),round(mean(w0))) = nn;
end
zzshow(spMap)

spSeedMap = zeros(H,W);
spSeedMap(spSeedVec) = 1:numel(spLst);

ov0 = plt.regionMapWithData(spLst,zeros(H,W),0.3); %zzshow(ov0);
for ii=1:3
    tmp = ov0(:,:,ii); 
   tmp(tmp==0 & m0s>0) = 255;
    if ii==1
        tmp(spCenterMap>0) = 255;
    end
    ov0(:,:,ii) = tmp;
end
zzshow(ov0);


%% graph
idx0 = find(m0Msk>0);
[~,~,it0] = ind2sub(size(m0Msk),idx0);
rgt00 = max(min(it0)-5,1):min(max(it0)+5,T);
dat = double(dFip(:,:,rgt00));

[ih0,iw0] = find(m0s>0);
gapSeed = max(ceil(max(max(ih0)-min(ih0),max(iw0)-min(iw0))/10/2),5);
[ref,tst,refBase,s,t,idxGood] = gtw.sp2graph(dat,m0s,spLst,spSeedVec(1),gapSeed);

%% gtw
spLst1 = spLst(idxGood);
spSeedVec1 = spSeedVec(idxGood);
spSz1 = cellfun(@numel,spLst1);
s2 = s00^2;
% s2 = s00^2./sqrt(spSz1);
% s2 = s00^2./spSz1;
smoBase = 0.1;
maxStp = 6;
tic
[ ss,ee,gInfo ] = gtw.buildGTWGraph( ref, tst, s, t, smoBase, maxStp, s2);
[~, labels1] = aoIBFS.graphCutMex(ss,ee);
path0 = gtw.label2path4Aosokin( labels1, ee, ss, gInfo );
toc

% warped curves
pathCell = cell(H,W);
vMap1 = zeros(H,W);
vMap1(spSeedVec1) = 1:numel(spSeedVec1);
for ii=1:numel(spLst1)
    [ih0,iw0] = ind2sub([H,W],spSeedVec1(ii));
    pathCell{ih0,iw0} = path0{ii};
end
datWarp = gtw.warpRef2Tst(pathCell,refBase/max(refBase(:)),vMap1,[H,W,numel(refBase)]);

zzshow(datWarp)

%% output
dVec = reshape(datWarp,[],numel(refBase));
dVec = dVec(spSeedVec1,:);
f1 = ['D:\neuro_WORK\glia_kira\tmp\superevents\',f0,'_seeds_4221.mat'];
save(f1,'dVec','s','t','spLst1','spSeedVec1','dFInfo','refBase','tst');


%% detect propagations
T1 = numel(refBase);
xI = zeros(H,W,T1);
for tt=1:T1
    tmp = zeros(H,W);
    w0 = datWarp(:,:,tt);
    for nn=1:numel(spLst1)
        sp00 = spLst1{nn};
        tmp(sp00) = w0(spSeedVec1(nn));
    end
    xI(:,:,tt) = tmp;
end
zzshow(xI)

zzshow(xI>0.9)

xI1 = xI; xI1(xI<0.5) = 0; xI1 = 2*(xI1-0.4);
zzshow(xI1)

xR = xI.*dFInfo*2;
zzshow(xR)

xDif1 = datWarp(:,:,2:end)-datWarp(:,:,1:end-1);
zzshow(xDif1*2)

xDif = xR(:,:,2:end)-xR(:,:,1:end-1);
zzshow(xDif*2)

%% major change of intensity
dat2 = rr.dat.^2;
datMA2 = movmean(dat2,ceil(T/5),3);
datBase2 = min(datMA2,[],3);
dF2 = dat2 - datBase2;
dFDif2 = (dF2(:,:,1:end-1) - dF2(:,:,2:end)).^2;
s002 = double(sqrt(median(dFDif2(:))/2));

dat2Smo = imgaussfilt(dat2,2);
% dat2Smo = dat2;
dDif2 = dat2Smo(:,:,2:end) - dat2Smo(:,:,1:end-1);
zzshow(dDif2);
zzshow(dDif2>4*s002)


