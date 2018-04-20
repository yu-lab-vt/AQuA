%% save
p0 = 'D:\neuro_WORK\glia_kira\tmp\propRaw\';
f0 = '2x_135um_reg_gcampwLP_10min_moco_Substack (301-500)';
seLst = label2idx(lblMapC1);
save([p0,f0,'_res.mat'],'seLst','opts');
dat_uint8 = uint8(dat.^2*256);
save([p0,f0,'_dat.mat'],'dat_uint8');
df_uint8 = uint8(dF*256);
save([p0,f0,'_dF.mat'],'df_uint8');

%% load
p0 = 'D:\neuro_WORK\glia_kira\tmp\propRaw\';
f0 = '2x_135um_reg_gcampwLP_10min_moco_Substack (301-500)';
load([p0,f0,'_res.mat']);
load([p0,f0,'_df.mat']);
df = double(df_uint8)/255;

% an event
seSel = 600;
% [dRecon1,riseLst1] = gtw.procMovie(df,seLst,seSel,1,opts);
[dRecon0,riseMap,riseLst] = gtw.procMovie(df,seLst,seSel,0,opts);

%% super event propagation
% four directions
[H,W,~] = size(dRecon0);
lmkMsk4 = fts.getLmk4Sides(H,W);
resProp = fts.evt2lmkProp1Wrap(dRecon0,seLst(seSel),lmkMsk4);

pixTwd = resProp.pixelToward{1};
pixTwdSum = sum(pixTwd,3);
pixTwdNorm = pixTwd./pixTwdSum;

figure;imagesc(pixTwdSum);colorbar

x11 = pixTwdNorm(:,:,3);
% x11 = pixTwd(:,:,4);
% x11(pixTwdSum<100) = nan;
figure;imagesc(x11,'AlphaData',~isnan(x11));colorbar











