%% weak burst
dif00 = datOrg(:,:,103)-datOrg(:,:,100);
zzshow(dif00);

[H,W,T] = size(datOrg);
x = 338; y = 53;
% x = 304; y = 211;
xrg = x-100:x+100; yrg = y-30:y+30;
c = datOrg(yrg,xrg,:);
cm = nanmean(reshape(c,[],T),1);
figure;plot(cm);


%% remove activities
datBg = datOrg;
for ii=1:numel(svLst)
    datBg(svLst{ii}) = nan;
end
datBgImp = img.imputeMov(datBg);


%% PCA
datBgImpRz = imresize(datBgImp,[64,64]);

x = 35; y = 7; xrg = x-10:x+10; yrg = y-5:y+5;
c = datBgImpRz(yrg,xrg,:); cm = nanmean(reshape(c,[],T),1); figure;plot(cm);

datxx = reshape(datBgImpRz,[],T)';
datxxM = mean(datxx,1);
[coeff,score,latent] = pca(datxx,'NumComponents',10);

figure;plot(score)
figure;plot(score(:,1:4))

datxxZ = zscore(datxx,1);
for ii=1:4
    cf0 = score(:,ii);
    cf0 = zscore(cf0);
    rho0 = mean(datxxZ.*cf0,1);
    rho0x = reshape(rho0,64,64);
    figure;imagesc(abs(rho0x));colorbar
    zzshow(abs(rho0x)>0.3)
end


for ii=1:4
    cf0 = reshape(coeff(:,ii),64,64);
    figure;imagesc(cf0);colorbar    
end


datBg1Rec = score*coeff'+datxxM;
datBg1Rec = reshape(datBg1Rec',size(datBg1));
zzshow(datBg1Rec)

datBg1RecFluc = score*coeff';
datBg1RecFluc = reshape(datBg1RecFluc',size(datBg1));

x = 35; y = 7; xrg = x-10:x+10; yrg = y-5:y+5;
c = datBg1Rec(yrg,xrg,:); cm = nanmean(reshape(c,[],T),1); figure;plot(cm);

datBg1DeTrend = datBg1 - datBg1RecFluc;

x = 35; y = 7; xrg = x-10:x+10; yrg = y-5:y+5;
c = datBg1DeTrend(yrg,xrg,:); cm = nanmean(reshape(c,[],T),1); figure;plot(cm);

datOrgFluc = imresize(datBg1RecFluc,[H,W]);
datOrgDeTrend = datOrg - datOrgFluc;
zzshow(datOrgDeTrend)

io.writeTiffSeq('D:\test.tiff',datOrgDeTrend,8);




