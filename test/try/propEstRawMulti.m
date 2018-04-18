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
load([p0,f0,'_dat.mat']);
load([p0,f0,'_df.mat']);

dat = double(dat_uint8)/255;
df = double(df_uint8)/255;
[H,W,T] = size(dat);

mapx = zeros(H,W,T);
for nn=1:numel(seLst)
    mapx(seLst{nn}) = nn;
end
% ov1 = plt.regionMapWithData(uint32(mapx),dat,0.25); zzshow(ov1);

% an event
seSel = 600;
gaphw = 10;
[ih0,iw0,it0] = ind2sub([H,W,T],seLst{seSel});
rgh = max(min(ih0)-gaphw,1):min(max(ih0)+gaphw,H);
rgw = max(min(iw0)-gaphw,1):min(max(iw0)+gaphw,W);
rgt = max((min(it0)-2),1):min((max(it0)+2),T);
% H0 = numel(rgh);
% W0 = numel(rgw);
% T0 = numel(rgt);
m0 = mapx(rgh,rgw,rgt);
df0 = df(rgh,rgw,rgt);
varEst = opts.varEst;

%% GTW on movie with super pixels
% input: df0, m0, seSel, varEst

varEstSp = varEst/16;
smoBase = 0.01;
maxStp = 11;

vMap0 = sum(m0==seSel,3)>0;
vMap0Hole = imfill(vMap0,8,'holes')-vMap0;
vMap0SmallHole = vMap0Hole - bwareaopen(vMap0Hole,4,4);
vMap0(vMap0SmallHole>0) = 1;

[df0ip,dfm,intMap,spSz,spLst] = gtw.dfMov2sp(df0,m0,vMap0,seSel,varEst);
[ref,tst,refBase,s,t] = gtw.sp2graph(df0ip,vMap0,spLst,varEst);

tic
[ ss,ee,gInfo ] = gtw.buildGTWGraph( ref, tst, s, t, smoBase, maxStp, varEstSp);
[~, labels1] = aoIBFS.graphCutMex(ss,ee);
toc
path0 = gtw.label2path4Aosokin( labels1, ee, ss, gInfo );

[datWarpInt,rMapAvg,datWarp] = gtw.anaGridPath(path0,spLst,dfm,vMap0,intMap,spSz,refBase);

%% propagation direction























