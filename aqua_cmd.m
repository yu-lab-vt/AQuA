%% file and path
% -- set folder name (p0), file name (f0) and preset
% -- preset 1: in vivo. preset 2: ex vivo
startup;  % initialize

preset = 1;
% preset = 2;

p0 = 'D:\neuro_WORK\glia_kira\tmp\Mar14_InVivoDataSet\';
f0 = '2x_135um_reg_gcampwLP_10min_moco_Substack (301-500).tif';
% f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001_Substack (1401-1500).tif';
% f0 = '2799747(2)_TS_1x_reg-001.tif';
% f0 = '2826451(4)_1_2_4x_140um_dualwv-001.tif';

frameRate = 1;  % second per frame
spatialRes = 1;  % micrometer per pixel edge

% >> RUN
opts = util.parseParam(preset,0,'./cfg/parameters1.xlsx');
opts.frameRate = frameRate;
opts.spatialRes = spatialRes;

% read data
% -- minimum size of events (in pixels)
% opts.minSize = 8;

% -- avoid near boundary pixels (useful after motion correction)
%opts.crop = 10;

% >> RUN
[dat,dF,opts,H,W,T] = burst.prep1(p0,f0,[],opts);

%% coarse detection
% -- if many signal missed in coarse detection, set a small value (like 2)
% -- otherwise, set a larger one (like 3)
opts.thrARScl = 1.5;

% -- spatial smoothing. Larger value for noisier data. Default is 0.5
%opts.smoXY = 0.5;

% >> RUN
[dat,datSmo,dL,arLst,lmLoc,lmLocR] = burst.actTop(dat,dF,opts);

% -- show results for this step
% -- if activities missed, decrease opts.thrARScl and/or increase opts.smoXY
if 0
    dataScale = 1;  % brightness of the data
    voxScale = 0.5;  % brightness of the overlay
    ov0 = plt.regionMapWithData(arLst,dat.^2*dataScale,voxScale,[],[],[],[],size(dat));
    zzshow(ov0);
    clear ov0
end

%% super pixel detection
% -- temporal separation threshold in fine detection.
% -- Set smaller (like 1) if events are missed; otherwise, set larger
opts.thrTWScl = 2;

% -- set smaller to incluede noiser pixels
opts.thrExtZ = 3;

% >> RUN
[lblMapS,~,riseX,riseMap] = burst.spTop(dat,dF,dL>-1,datSmo,lmLoc,lmLocR,opts);

%% Get events from super pixels
% -- Features
% -- evtLst: voxel lcations of each event (in linear index)
% -- ftsLst: features for events
% -- dffMat: delta F/F0 curves for each event

% -- set a larger value for larger events in fine detection
opts.cRise = 3;

% -- propagation continuity in fine detection.
% -- Set larger to allow slower propagation
opts.cDelay = 3;

% -- (advanced) repeated sparklings at same location
% -- allowed to be within the same event if set > 1.
% -- If do not allow, set to 0.5
opts.cOver = 0.1;

% -- refine rising time estimation
opts.reSeg = 0;

% -- smooth the rising time refinement
% opts.reSegGtwSmo = 1;

% -- if propagation pattern is not detail enough, decrease this
% -- 0.1 to 2+
% opts.evtGtwSmo = 0.5;

% >> RUN
[fts,evt,dffMat,dRecon,~,~,lblMapE] = burst.evtTop(...
    dat,datSmo,dF,dL,lblMapS,riseMap,opts);

%% visualize and export
res = burst.gatherRes(dat,opts,evt,fts,dffMat,lblMapE,dRecon);

% use aqua_gui for remaining tasks, like drawing cells and soma
aqua_gui(res);

% save(['D:\',opts.fileName,'_res.mat'],'res');





