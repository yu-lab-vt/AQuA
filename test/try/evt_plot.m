% local maximums
lmAll = zeros(H,W,T); lmAll(lmLoc) = 1;
tmp = zeros(H,W,3,T); tmp(:,:,1,:) = lmAll;
tmp(:,:,2,:) = dat.^2; 
% tmp(:,:,3,:) = 0.3*(lblMapS>0);
zzshow(tmp);

% regions
ov0 = plt.regionMapWithData(dL,dat,0.25); zzshow(ov0);

ov1 = plt.regionMapWithData(lblMap,dat.^2,0.25); zzshow(ov1);

ov1 = plt.regionMapWithData(lblMapS,dat.^2,0.25); zzshow(ov1);

ov1 = plt.regionMapWithData(lblMapC1,dat.^2*0.5,0.25); zzshow(ov1);
ov1 = plt.regionMapWithData(lblMapC,dat.^2*0.3,0.25); zzshow(ov1);

ov1 = plt.regionMapWithData(lblMapCx,dat.^2*0.3,0.25); zzshow(ov1);

ov1 = plt.regionMapWithData(evt,evt*0,0.5); zzshow(ov1);


figure;imagesc(rMapAvg,'AlphaData',~isnan(rMapAvg));colorbar;





