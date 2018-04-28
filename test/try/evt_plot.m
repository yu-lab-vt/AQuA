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

ov1 = plt.regionMapWithData(seMap,dat,0.25); zzshow(ov1);
ov1 = plt.regionMapWithData(lblMapC,dat.^2*0.3,0.25); zzshow(ov1);

ov1 = plt.regionMapWithData(lblMapCx,dat.^2*0.3,0.25); zzshow(ov1);

ov1 = plt.regionMapWithData(datL,double(dat),0.5,double(datR)/255); zzshow(ov1);
% ov1 = plt.regionMapWithData(evtL,double(dat).^2*0.5,0.25,double(datR)/255); zzshow(ov1);

ov1 = plt.regionMapWithData(evtLst,dat,0.5); zzshow(ov1);

xx = double(riseMap(:,:,23));
xx(xx==0) = inf;
figure;imagesc(xx,'AlphaData',~isinf(xx));colorbar

ov1 = plt.regionMapWithData(evt,evt*0,0.5); zzshow(ov1);

ov1 = plt.regionMapWithData(spLst,dlyMap*0,0.5); zzshow(ov1);
spMap = dlyMap*0;
for nn=1:numel(spLst)
    spMap(spLst{nn}) = nn;
end
figure;imagesc(spMap,'AlphaData',spMap>0);colorbar


ov1 = plt.regionMapWithData(evtL,double(dF(rgh,rgw,rgtx)),0.5,evtRecon); zzshow(ov1);
ov1 = plt.regionMapWithData(evtL,double(dF(rgh,rgw,rgtx)),0.5,double(evtRecon)/255); zzshow(ov1);

figure;imagesc(rMapAvg,'AlphaData',~isnan(rMapAvg));colorbar;

figure;imagesc(dlyMap,'AlphaData',~isinf(dlyMap));colorbar
figure;imagesc(dlyMap0,'AlphaData',~isinf(dlyMap0));colorbar
figure;imagesc(dlyMap1,'AlphaData',~isinf(dlyMap1));colorbar

[~,riseMap,riseX] = burst.getSpDelay(dat,lblMapS,opts);

ov0 = plt.regionMapWithData(spLst,zeros(size(dlyMap)),0.5); zzshow(ov0);