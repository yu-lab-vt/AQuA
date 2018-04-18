function res = detectGrowRegion1(dat,mskST,pix,opts,rgH,rgW,rgT)
%detectGrowRegion1 detect events in a region

if 0
    load('D:\neuro_WORK\glia_kira\tmp\bst20180206\matlab1.mat');
    opts.gtwSmo = 2; opts.blkGapSeed = 5;
    opts.thrx = 3*sqrt(opts.varEst);
end

res = [];
[H,W,T] = size(dat);
thrx = opts.thrx;
datSmo = zeros(size(dat));
for tt=1:T
    datSmo(:,:,tt) = imgaussfilt(dat(:,:,tt),2);
end
mskSig = zeros(H,W,T);
mskSig(pix) = 1;

% find seeds
% fsz = [1.5 1.5 0.5];
fsz = [2 2 0.5];
[lmLoc,lmVal,lm3Idx] = burst.getLocalMax3D(dat,mskST,mskSig,fsz);
if isempty(lmLoc)
    return
end
nLm = numel(lmVal);
if nLm>100
    fprintf('Seed number: %d\n',nLm)
end

% initial fitting for time window
[resCellInit,lblMapInit] = burst.detectGrowRegionOneStep(...
    dat,datSmo,cell(nLm,1),zeros(H,W,T),lmLoc,lmVal,lm3Idx,mskSig,opts,thrx,0);
if nanmax(lblMapInit(:))==0
    return
end

% fitting for regions
resCell = resCellInit;
lblMap = lblMapInit;
for pp=1:30
    [resCell,lblMap] = burst.detectGrowRegionOneStep(...
        dat,datSmo,resCell,lblMap,lmLoc,lmVal,lm3Idx,mskSig,opts,thrx,pp);
end
lblMapF = burst.gatherPatch(lblMap,lm3Idx,resCell);

%% Extend and re-fit each patch, estimate delay, reconstruct signal
[lblMapS,dRecon,riseX] = burst.alignPatchShort(dat,datSmo,lblMapF,opts);
if isempty(riseX)
    return
end

% patch to components
% try
%     if isempty(riseX)
%         return
%     end
% lblMapC = burst.sp2EvtTree(lblMapS,riseX,10,10,0.5);
% lblMapC = burst.sp2EvtTreeFast(lblMapS,riseX,5,5,0.5);

% tmp = zeros(H,W,3,T); tmp(:,:,1,:) = lm3Idx; tmp(:,:,2,:) = dat.^2; zzshow(tmp);
% ov1 = plt.regionMapWithData(lblMapInit,dat.^2/2,5); zzshow(ov1);
% ov1 = plt.regionMapWithData(lblMap,dat.^2/2,5); zzshow(ov1);
% ov1 = plt.regionMapWithData(lblMapF,dat.^2,5); zzshow(ov1);
% ov1 = plt.regionMapWithData(lblMapS,dat.^2,5); zzshow(ov1);
% ov1 = plt.regionMapWithData(lblMapC,zeros(H,W,T),2); zzshow(ov1);
% ov1 = plt.regionMapWithData(lblMapC,dat.^2,3); zzshow(ov1);
% ov1 = plt.regionMapWithData(lblMapC,dat.^2,3,[],dRecon); zzshow(ov1);

% output
% res.evt = lblMapC;
res.rc = dRecon;
res.sp = lblMapS;
res.spRise = riseX;
res.rgH = rgH;
res.rgW = rgW;
res.rgT = rgT;

end



