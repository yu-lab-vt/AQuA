%% setup
% -- preset 1: in vivo. 2: ex vivo. 3: GluSnFR
startup;  % initialize

preset = 1;
p0 = 'D:\neuro_WORK\glia_kira\raw\Mar14_InVivoDataSet\';
f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001.tif';
% preset = 2;
% p0 = 'D:\neuro_WORK\glia_kira\raw\TTXDataSetRegistered_32Bit\';
% f0 = 'FilteredNRMCCyto22m_slice2_Baseline2_Layer2_3-008cycle1channel1.tif';
% f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1.tif';
% preset = 4;
% p0 = 'D:\neuro_WORK\glia_kira\raw\GluSnFR_20180511\';
% f0 = 'hsyn-102816-Slice1-ACSF-Baseline-006_reg.tif';
% f0 = 'test_detrend.tiff';
% f0 = 'Substack (501-1000).tif';
% preset = 5;
% p0 = 'D:\neuro_WORK\glia_kira\tmp\superNoisy\';
% f0 = '180504_s1_T_ctk-DA_zoom.tif';

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
[svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,opts);  % super voxel detection

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

ov1 = plt.regionMapWithData(arLst,datOrg,0.5); zzshow(ov1);
ov1 = plt.regionMapWithData(svLst,datOrg,0.5); zzshow(ov1);
ov1 = plt.regionMapWithData(seLst,datOrg,0.5,datR); zzshow(ov1);
ov1 = plt.regionMapWithData(evtLst,datOrg,0.5,datR); zzshow(ov1);
ov1 = plt.regionMapWithData(evtLstFilterZ,datOrg,0.5,datR); zzshow(ov1);
ov1 = plt.regionMapWithData(evtLstMerge,datOrg,0.5,datR); zzshow(ov1);
[ov1,lblMapS] = plt.regionMapWithData(evtLstE,datOrg,0.5,datRE); zzshow(ov1);


