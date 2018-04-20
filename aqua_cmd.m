%% event detection
% Output
% evtLst  : voxel lcations of each event (in linear index)
% ftsLst  : features for events
% dffMat  : delta F/F0 curves for each event
% riseLst : rising map of each super event

% file and path
% -- set folder name (p0), file name (f0) and preset
% -- preset 1: in vivo. preset 2: ex vivo
startup;  % initialize

preset = 1;
% preset = 2;

p0 = 'D:\neuro_WORK\glia_kira\tmp\Mar14_InVivoDataSet\';
% f0 = '2x_135um_reg_gcampwLP_10min_moco_Substack (301-500).tif';
f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001_Substack (1401-1500).tif';
% f0 = '2799747(2)_TS_1x_reg-001.tif';
% f0 = '2826451(4)_1_2_4x_140um_dualwv-001.tif';

frameRate = 1;  % second per frame
spatialRes = 1;  % micrometer per pixel edge

opts = util.parseParam(preset,0,'./cfg/parameters1.xlsx');
opts.frameRate = frameRate;
opts.spatialRes = spatialRes;

% read data
%opts.minSize = 8;  % minimum size of events (in pixels)
%opts.crop = 10;  % avoid near boundary pixels (useful after motion correction)
[dat,dF,opts] = burst.prep1(p0,f0,[],opts);

%% coarse detection
% if activities missed, decrease opts.thrARScl and/or increase opts.smoXY
opts.thrARScl = 1;  % if many signal missed in coarse detection, set a small value (like 2)
%opts.smoXY = 0.5;  % spatial smoothing. Larger value for noisier data. Default is 0.5
[arLst,lmLoc] = burst.actTop(dat,dF,opts);

ov0 = plt.regionMapWithData(arLst,dat.^2,0.5); zzshow(ov0); clear ov0

%% super pixel detection
opts.thrTWScl = 2;  % temporal separation threshold in fine detection
opts.thrExtZ = 0.5;  % set smaller to incluede noiser pixels
[lblMapS,~,riseX,riseMap] = burst.spTop(dat,dF,lmLoc,opts);

%% Get events from super pixels
opts.cRise = 5;  % set a larger value for larger events in fine detection
opts.cDelay = 5;  % propagation continuity, set larger to allow slower propagation
[fts,evt,dffMat,riseLst,dRecon,lblMapE] = burst.evtTop(dat,dF,lblMapS,riseMap,opts);

%% visualize and export
res = burst.gatherRes(dat,opts,evt,fts,dffMat,lblMapE,dRecon);
aqua_gui(res);  % use aqua_gui for remaining tasks, like drawing cells and soma
% save(['D:\',opts.fileName,'_res.mat'],'res');





