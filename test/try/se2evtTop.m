% normalize data to super pixels containing simialr information about phase

f0 = '2x_135um_reg_gcampwLP_10min_moco_Substack (301-500)';
% f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001_Substack (1401-1500)';
rr = load(['D:\neuro_WORK\glia_kira\tmp\superevents\',f0,'.mat']);
dat = rr.dat;
lblMapS = rr.lblMapS;
riseMap = rr.riseMap;
opts = rr.opts;

[ftsx,evt,dffMat,dMat,datR,datL] = burst.evtTop(dat,lblMapS,riseMap,opts);

ov0 = plt.regionMapWithData(seMap,dat.^2*0.5,0.25); zzshow(ov0);
ov3 = plt.regionMapWithData(datL,dat,0.5,datR); zzshow(ov3);























