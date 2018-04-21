%% normalize data to super pixels containing simialr information about phase
load('D:\neuro_WORK\glia_kira\tmp\debug\rising.mat')

[H0,W0,T0] = size(df0);

m0s = sum(m0==seSel,3)>0;
nPixValid = sum(m0s(:)>0);

% impute other events
df0(m0>0 & m0~=seSel) = nan;
df0ip = gtw.imputeMov(df0);

% dfm = nanmean(df0ip,3);
% dfm = medfilt2(dfm);
dfmax = max(movmean(df0ip,5,3),[],3);
dfmax = medfilt2(dfmax);
% dfvar = nanvar(df0ip,0,3);
% dfvar = medfilt2(dfvar);

dfInfo = dfmax;  % information in each pixel, for peak SNR
% dReli = dfm;  % reliability of the feature of each pixel
dfInfo(isnan(dfInfo)) = 0;
dfInfo(m0s==0) = 0;

infoTot = sum(dfInfo(:));
nSpTgt = min(100*100*70/T0,nPixValid/4);
infoSp = infoTot/nSpTgt;
% figure;imagesc(dfInfo);colorbar

% rising time as feature
s00 = sqrt(opts.varEst);
% thrMax = ceil(quantile(df0ip(:),0.99)/s00);
thrMax = ceil(nanmax(df0ip(:))/s00*2)/2;
thrVec = 0:0.5:thrMax;
dFx = df0ip;
Sx = 1*(m0==seSel);
tMapMT = burst.getSuperEventRisingMapMultiThr(dFx,Sx,thrVec,s00);
% tMapMT = gtw.getMovPixelMapMultiThr(dFx,Sx,thrVec,s00);
m0sx = sum(~isnan(tMapMT))>0;

% for ii=1:numel(thrVec)
%     x00 = tMapMT(:,:,ii);
%     figure;imagesc(x00,'AlphaData',~isnan(x00));colorbar;pause(0.1)
% end

% % empirical feature uncertainty
% srt00 = nan(numel(thrVec),1);
% for ii=1:numel(thrVec)
%     x00 = tMapMT(:,:,ii);
%     dif00 = (x00(:,1:end-1)-x00(:,2:end)).^2;
%     dif00 = dif00(~isnan(dif00));
%     dif01 = (x00(1:end-1,:)-x00(2:end,:)).^2;
%     dif01 = dif01(~isnan(dif01));
%     dif02 = (x00(1:end-1,1:end-1)-x00(2:end,2:end)).^2;
%     dif02 = dif02(~isnan(dif02));
%     dif0x = [dif00;dif01;dif02];
%     if numel(dif0x)>20
%         srt00(ii) = sqrt(nanmedian(dif0x(:)));
%     end
% end

%% region growing
availMap = m0s>0 & m0sx>0;
[dIx,dIix] = sort(dfInfo(:),'descend');
mapx = zeros(H0,W0);
mapx(dIix) = 1:H0*W0;
dIx(availMap==0) = 0;
spLst = cell(1);
nSp = 1;
for nn=1:numel(dIx)
    if dIx(nn)==0
        continue
    end
    iSeedIn = dIix(nn);
    
    if nSp==548
%         keyboard
    end
    
    % extract region
    [ihSeed,iwSeed] = ind2sub([H0,W0],iSeedIn);
    rgh = max(ihSeed-10,1):min(ihSeed+10,H0);
    rgw = max(iwSeed-10,1):min(iwSeed+10,W0);
    H1 = numel(rgh);
    W1 = numel(rgw);
    ihSeed = ihSeed-min(rgh)+1;
    iwSeed = iwSeed-min(rgw)+1;
    iSeed = sub2ind([H1,W1],ihSeed,iwSeed);
    
    dI0 = dfInfo(rgh,rgw);
    xInfo = dI0(ihSeed,iwSeed);
    ft = tMapMT(rgh,rgw,:);
    availMap0 = availMap(rgh,rgw);
    availMap0(ihSeed,iwSeed) = false;
    
    % distances: delay, intensity and distance
    ftBase = reshape(ft(ihSeed,iwSeed,:),1,[]);
    ftVec = reshape(ft,[],size(ft,3));
    distDelay = nanmedian(abs(ftVec - ftBase),2);
    distDelay(isnan(distDelay)) = Inf;
    distInt = abs(sum(isnan(ftVec),2)-sum(isnan(ftBase)));
    [ih1,iw1] = find(ones(H1,W1));
    distEuc = sqrt((ihSeed-ih1).^2+(iwSeed-iw1).^2);
    %maxDistEuc = sqrt(infoSp/xInfo)*1.5;
    %distEuc(distEuc>maxDistEuc) = Inf;
    distx = distDelay+distInt*0.5+distEuc*2;
    distx = reshape(distx,H1,W1);
    %figure;imagesc(distx,'AlphaData',~isinf(distx));colorbar
    
    % region growing
    neibSet = [];
    newPix = iSeed;    
    pixSet =iSeed;
    for ii=1:100
        [ih2,iw2] = ind2sub([H1,W1],newPix);
        h00 = [min(ih2+1,H1),max(ih2-1,1),ih2,ih2];
        w00 = [iw2,iw2,max(iw2-1,1),min(iw2+1,W1)];
        newCand = unique(sub2ind([H1,W1],h00,w00));
        newCand = newCand(availMap0(newCand));
        neibSet = union(neibSet,newCand);
        if isempty(neibSet)
            break
        end
        neibDist = distx(neibSet);
        [~,ix] = min(neibDist);
        newPix = neibSet(ix);
        availMap0(newPix) = false;
        pixSet = union(pixSet,newPix);
        neibSet = setdiff(neibSet,newPix);
        xInfo = xInfo+dI0(newPix);
        if xInfo>=infoSp
            break
        end
    end
    availMap(rgh,rgw) = availMap(rgh,rgw).*availMap0;
    [ihx,iwx] = ind2sub([H1,W1],pixSet);
    spLst0 = sub2ind([H0,W0],ihx+min(rgh)-1,iwx+min(rgw)-1);
    dIx(mapx(spLst0)) = 0;    
    %pixMap = zeros(H1,W1); pixMap(pixSet) = 1; zzshow(pixMap)
    
    if xInfo<infoSp
        continue
    end
    spLst{nSp} = spLst0;    
    %ov0 = plt.regionMapWithData(spLst,zeros(H0,W0),0.5); zzshow(ov0);
    nSp = nSp+1;
    if mod(nSp,1000)==0
        fprintf('%d\n',nSp)
        break
    end
end

ov0 = plt.regionMapWithData(spLst,zeros(H0,W0),0.5); zzshow(ov0);

spMap = zeros(H0,W0);
for nn=1:numel(spLst)
    spMap(spLst{nn}) = nn;
end
zzshow(spMap)


%% test and refererence curves
df0Vec = reshape(df0,[],T0);
nSp = numel(spLst);
tst = zeros(nSp,T0);
ref = zeros(nSp,T0);
refBase = nanmean(df0Vec,1);
for ii=1:numel(spLst)
    sp0 = spLst{ii};
    if ~isempty(sp0)
        tst0 = nanmean(df0Vec(sp0,:),1);
        k0 = std(tst0)/std(refBase);
        ref0 = refBase*k0;
        tst(ii,:) = tst0;
        ref(ii,:) = ref0;
    end
end

% idx = L(413,294);
% idx = L(419,285);
% idx = L(409,285);
% figure;plot(ref(idx,:));hold on;plot(tst(idx,:));

% graph
s = nan(nSp,1);
t = nan(nSp,1);
nPair = 0;
dh = [-1 0 1 -1 1 -1 0 1];
dw = [-1 -1 -1 0 0 1 1 1];
for ii=1:numel(spLst)
    sp0 = spLst{ii};
    [ih,iw] = ind2sub([H0,W0],sp0);
    for jj=1:numel(dh)
        ih = ih+dh(jj);
        iw = iw+dw(jj);
        idxOK = ih>0 & ih<=H0 & iw>0 & iw<=W0;
        ih = ih(idxOK);
        iw = iw(idxOK);
        ihw = sub2ind([H0,W0],ih,iw);
        if ~isempty(ihw)
            idx = L(ihw);
            idx = unique(idx(idx>ii));
            if ~isempty(idx)
                for kk=1:numel(idx)
                    nPair = nPair+1;
                    s(nPair) = ii;
                    t(nPair) = idx(kk);
                end
            end
        end
    end
end


%% gtw
nVar = opts.varEst/4;
smoBase = 0.01;
maxStp = 15;
[ ss,ee,gInfo ] = gtw.buildGTWGraph( ref, tst, s, t, smoBase, maxStp, nVar);
[~, labels1] = aoIBFS.graphCutMex(ss,ee);
path0 = gtw.label2path4Aosokin( labels1, ee, ss, gInfo );

% warped curves
pathCell = cell(H0,W0);
vMap1 = zeros(H0,W0);
for ii=1:nSp
    sp0 = spLst{ii};
    [ih,iw] = ind2sub([H0,W0],sp0);
    ih0 = round(mean(ih));
    iw0 = round(mean(iw));
    pathCell{ih0,iw0} = path0{ii};
    vMap1(ih0,iw0) = 1;
end
datWarp = gtw.warpRef2Tst(pathCell,refBase/max(refBase(:)),vMap1,[H0,W0,T0]);

zzshow(datWarp)





























