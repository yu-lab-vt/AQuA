%% useful
ov1 = plt.regionMapWithData(lblMapS,dat.^2,0.25); zzshow(ov1);
ov1 = plt.regionMapWithData(seMap,dat.^2*0.5,0.25); zzshow(ov1);
ov1 = plt.regionMapWithData(lblMapC,dat.^2*0.3,0.25); zzshow(ov1);
figure;imagesc(rMapAvg,'AlphaData',~isnan(rMapAvg));colorbar;

%% pixel strength and rough rising time map
figure;imagesc(dFInfo);
set(gca,'Position',[0 0 1 1],'DataAspectRatio',[H W 1]);

rise2d = nanmean(tMapMT,3);
rise2d(m0s==0) = nan;
figure;imagesc(rise2d,'AlphaData',~isnan(rise2d));colorbar

for ii=1:numel(thrVec)
    x00 = tMapMT(:,:,ii);
    figure;imagesc(x00,'AlphaData',~isnan(x00));colorbar;pause(0.1)
end

%% super pixels
spMap = zeros(H,W);
spCenterMap = zeros(H,W);
spCntMap = zeros(H,W);
% for nn=5905
for nn=1:numel(spLst)
    sp0 = spLst{nn};
    if ~isempty(sp0)
        spMap(spLst{nn}) = nn;
    end
    [h0,w0] = ind2sub([H,W],sp0);
    spCenterMap(round(mean(h0)),round(mean(w0))) = nn;
    spCntMap(sp0) = spCntMap(sp0)+1;
end
zzshow(spMap)
figure;imagesc(spCntMap);colorbar

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

figure;hist(spStd,100);title('Sigma')
figure;hist(spSco,100);title('Score')
figure;hist(spSz,100);title('Size')

%% super events output
zzshow(datWarp)
dVec = reshape(datWarp,[],numel(refBase));
dVec = dVec(spSeedVec1,:);
f1 = ['D:\neuro_WORK\glia_kira\tmp\superevents\',f0,'_seeds_4084.mat'];
save(f1,'dVec','s','t','spLst1','spSeedVec1','dFInfo','refBase','tst','s2');

%% events
figure;hist(spDir,100)
figure;imagesc(dlyMap,'AlphaData',~isinf(dlyMap));colorbar;hold on
ov0 = plt.regionMapWithData(evtMap,evtMap*0,0.5); zzshow(ov0);

%% seed direction
% direction for each pair
nPair = numel(s);
spDir = zeros(nPair,1);  % around 0: mutual, 1: s->t, -1: t->s
spDly = nan(nPair,1);  % median delay for intensity that propagates
for nn=1:nPair
    s0 = s(nn);
    t0 = t(nn);
    d0 = tAch(s0,:)-tAch(t0,:);
    d0 = sum(d0)/numel(thrVec);
    spDir(nn) = d0;
    d0a = abs(d0)-2;
    d0a(d0a<0) = 0;
    spDly(nn) = sum(d0a);
end

ix = zeros(nPair,1);
iy = zeros(nPair,1);
iu = zeros(nPair,1);
iv = zeros(nPair,1);
[ySeed,xSeed] = ind2sub([H,W],spSeedNewLoc);
for ii=1:nPair
    if abs(spDir(ii))<0.6 || spDly(ii)>0
        continue
    end
    s00 = s(ii);
    t00 = t(ii);
    sx = xSeed(s00);
    sy = ySeed(s00);
    tx = xSeed(t00);
    ty = ySeed(t00);
    if spDir(ii)<0  % s-->t
        ix(ii) = sx;
        iy(ii) = sy;
        iu(ii) = tx-sx;
        iv(ii) = ty-sy;
    else  % t-->s
        ix(ii) = tx;
        iy(ii) = ty;
        iu(ii) = sx-tx;
        iv(ii) = sy-ty;
    end
end

% direction map
spSeedMap = zeros(H,W);
spSeedMap(spSeedNewLoc) = 1;
tmpx = cat(3,spSeedMap,dInfo,zeros(H,W));
figure;imshow(tmpx);hold on
quiver(ix,iy,iu,iv,0);
set(gca,'position',[0 0 1 1])

figure;imagesc(dlyMap,'AlphaData',~isinf(dlyMap));colorbar;hold on
f = quiver(ix,iy,iu,iv,0);
f.Color = 'red';
set(gca,'Position',[0 0 1 1],'DataAspectRatio',[H W 1]);

%% events misc
% one pair of seeds
nn = 246;
spSeedMap = zeros(H,W);
spSeedMap(spSeed(s(nn))) = 2;
spSeedMap(spSeed(t(nn))) = 1;
tmpx = cat(3,spSeedMap/2,dInfo,zeros(H,W));
zzshow(tmpx)

figure;plot(cx(s(nn),:));hold on;plot(cx(t(nn),:));

% warped data
dWarp = zeros(H*W,T);
dWarp(spSeed,:) = cx;
dWarp = reshape(dWarp,[H,W,T]);
zzshow(dWarp)

% raw data
f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001_Substack (1401-1500)';
rr = load(['D:\neuro_WORK\glia_kira\tmp\superevents\',f0,'.mat']);
zzshow(rr.dat.^2)





















