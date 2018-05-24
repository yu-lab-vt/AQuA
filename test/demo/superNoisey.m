p0 = 'D:\neuro_WORK\glia_kira\tmp\superNoisy\';
f0 = '180504_s1_T_ctk-DA_zoom.tif';
opts = util.parseParam(1);
[datOrg,opts] = burst.prep1(p0,f0,[],opts);  % read data
datRaw = datOrg.^2;

% mask based on correlation
corrMap = stat.getCorrMapAvg8(datRaw,1);
dif00 = (corrMap(:,1:end-1) - corrMap(:,2:end)).^2;
s00 = sqrt(nanmedian(dif00(:))/0.9133);
corrMapMed = medfilt2(corrMap);
msk = bwareaopen(corrMapMed>2*s00,8);
msk = imdilate(msk,strel('square',5));

datRaw1 = datRaw.*msk;

% curves
[H,W,T] = size(datRaw);
datRawVec = reshape(datRaw,[],T);

cc = bwconncomp(msk);
mskLbl = labelmatrix(cc);
for ii=1:cc.NumObjects
    x0 = datRawVec(cc.PixelIdxList{ii},:);
    x0m = mean(x0,1);
    x0m = x0m - median(x0m);
    s0m = sqrt(median((x0m(1:end-1)-x0m(2:end)).^2)/0.9113);
    figure;plot(x0m);    
end


%% misc
corrMapx = stat.getCorrMapAvg8(datRaw(:,:,1:20),1);

% plots
zzshow(corrMap*4)
zzshow(corrMapMed*4)
zzshow(msk)
zzshow(graythresh(datRawMean))

% median filter
datRawMean = mean(datRaw,3);


Y = fft2(datRawMean);
imagesc(abs((Y)))

zzshow(datRawMean.*corrMapMed*200)

datRawGau = imgaussfilt3(datRaw,[2,2]);
datRawMed2 = medfilt3(datRaw,[5,5,1]);
datRawMed = medfilt3(datRaw,[5,5,5]);
datOrgMed = medfilt3(datOrg,[5,5,5]);

% correlation in data
datZ = zscore(datRaw,0,3);
rhox = mean(datZ(:,1:end-1,:).*datZ(:,2:end,:),3);
rhoy = mean(datZ(1:end-1,:,:).*datZ(2:end,:,:),3);
rhoxM = nanmedian(rhox(:));
rhoyM = nanmedian(rhoy(:));




