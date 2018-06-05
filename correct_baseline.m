%% remove global trend in the movie
% use the same parameters as in the first two steps in event detection
% presets: 1, invivo. 2, exvivo. 3, glutamate. 4, glutamate with low SNR

startup;  % initialize

preset = 4;
p0 = 'D:\neuro_WORK\glia_kira\raw\GluSnFR_20180511\';
f0 = 'hsyn-102816-Slice1-ACSF-Baseline-006_reg.tif';

opts = util.parseParam(preset,0);

% read data
[datOrg,opts] = burst.prep1(p0,f0,[],opts);
[H,W,T] = size(datOrg);

% initial detection
[dat,dF,arLst,lmLoc,opts] = burst.actTop(datOrg,opts);  % foreground and seed detection
ov1 = plt.regionMapWithData(arLst,datOrg,0.5); zzshow(ov1); clear ov1

[svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,opts);  % super voxel detection
ov1 = plt.regionMapWithData(svLst,datOrg,0.5); zzshow(ov1); clear ov1

% remove activities to get background trend
datBg = datOrg;
for ii=1:numel(svLst)
    datBg(svLst{ii}) = nan;
end
datBgImp = img.imputeMov(datBg);


%% de-trend
nComp = 10;  % number of components in PCA

datBgImpRz = imresize(datBgImp,[64,64]);
datxx = reshape(datBgImpRz,[],T)';
[coeff,score,latent] = pca(datxx,'NumComponents',nComp);

datBg1RecFluc = score*coeff';
datBg1RecFluc = reshape(datBg1RecFluc',size(datBgImpRz));
datOrgFluc = imresize(datBg1RecFluc,[H,W]);
datOrgDeTrend = datOrg - datOrgFluc;


%% visualization
% re-constructed movie
zzshow(datOrgDeTrend);

% show top components
figure;plot(score(:,1:4))

% correlation map for each component
datxxZ = zscore(datxx,1);
for ii=1:4
    cf0 = score(:,ii);
    cf0 = zscore(cf0);
    rho0 = mean(datxxZ.*cf0,1);
    rho0x = reshape(rho0,64,64);
    figure;imagesc(abs(rho0x));colorbar
end

% coefficient map for each component
for ii=1:4
    cf0 = reshape(coeff(:,ii),64,64);
    figure;imagesc(cf0);colorbar    
end


%% output
io.writeTiffSeq('D:\test_detrend.tiff',datOrgDeTrend.^2);











