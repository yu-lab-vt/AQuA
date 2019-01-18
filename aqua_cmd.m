%% setup
% -- preset 1: in vivo. 2: ex vivo. 3: GluSnFR
startup;  % initialize

preset = 1;
p0 = 'D:\neuro_WORK\glia_kira\raw\Mar14_InVivoDataSet\';  % folder name
f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001.tif';  % file name

opts = util.parseParam(preset,0);

% opts.smoXY = 1;
% opts.thrARScl = 2;
% opts.movAvgWin = 15;
% opts.minSize = 8;
% opts.regMaskGap = 0;
% opts.thrTWScl = 5;
% opts.thrExtZ = 0.5;
% opts.extendSV = 1;
% opts.cRise = 1;
% opts.cDelay = 2;
% opts.zThr = 3;
% opts.getTimeWindowExt = 10000;
% opts.seedNeib = 5;
% opts.seedRemoveNeib = 5;
% opts.thrSvSig = 1;
% opts.extendEvtRe = 0;

[datOrg,opts] = burst.prep1(p0,f0,[],opts);  % read data

%% detection
[dat,dF,arLst,lmLoc,opts,dL] = burst.actTop(datOrg,opts);  % foreground and seed detection
[svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);  % super voxel detection

[riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts);  % events
[ftsLst,dffMat] = fea.getFeatureQuick(datOrg,evtLst,opts);

% fitler by significance level
mskx = ftsLst.curve.dffMaxZ>opts.zThr;
dffMatFilterZ = dffMat(mskx,:);
evtLstFilterZ = evtLst(mskx);
tBeginFilterZ = ftsLst.curve.tBegin(mskx);
riseLstFilterZ = riseLst(mskx);

% merging (glutamate)
evtLstMerge = burst.mergeEvt(evtLstFilterZ,dffMatFilterZ,tBeginFilterZ,opts);

% reconstruction (glutamate)
if opts.extendSV==0 || opts.ignoreMerge==0 || opts.extendEvtRe>0
    [riseLstE,datRE,evtLstE] = burst.evtTopEx(dat,dF,evtLstMerge,opts);
else
    riseLstE = riseLstFilterZ; datRE = datR; evtLstE = evtLstFilterZ;
end

% feature extraction
[ftsLstE,dffMatE,dMatE] = fea.getFeaturesTop(datOrg,evtLstE,opts);
ftsLstE = fea.getFeaturesPropTop(dat,datRE,evtLstE,ftsLstE,opts);

%% export to GUI
res = fea.gatherRes(datOrg,opts,evtLstE,ftsLstE,dffMatE,dMatE,riseLstE,datRE);
aqua_gui(res);

% visualize the results in each step
if 0
    ov1 = plt.regionMapWithData(arLst,datOrg,0.5); zzshow(ov1);
    ov1 = plt.regionMapWithData(svLst,datOrg,0.5); zzshow(ov1);
    ov1 = plt.regionMapWithData(seLst,datOrg,0.5,datR); zzshow(ov1);
    ov1 = plt.regionMapWithData(evtLst,datOrg,0.5,datR); zzshow(ov1);
    ov1 = plt.regionMapWithData(evtLstFilterZ,datOrg,0.5,datR); zzshow(ov1);
    ov1 = plt.regionMapWithData(evtLstMerge,datOrg,0.5,datR); zzshow(ov1);
    [ov1,lblMapS] = plt.regionMapWithData(evtLstE,datOrg,0.5,datRE); zzshow(ov1);
end


