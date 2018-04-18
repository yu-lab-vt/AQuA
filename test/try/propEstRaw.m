%% load
load('D:\neuro_WORK\glia_kira\tmp\propRaw\2x_135um_reg_gcampwLP_10min_moco_dat.mat')
load('D:\neuro_WORK\glia_kira\tmp\propRaw\2x_135um_reg_gcampwLP_10min_moco_dF.mat')
load('D:\neuro_WORK\glia_kira\tmp\propRaw\2x_135um_reg_gcampwLP_10min_moco_dL.mat')
load('D:\neuro_WORK\glia_kira\tmp\propRaw\2x_135um_reg_gcampwLP_10min_moco_res.mat')

dat = double(dat1)/255;
df = double(df1)/255;
[H,W,T] = size(dat);

mapx = zeros(H,W,T);
for nn=1:numel(lblxi)
    mapx(lblxi{nn}) = nn;
end

% ov1 = plt.regionMapWithData(uint32(mapx),dat,0.25); zzshow(ov1);

%% an event
evtSel = 4751;

gaphw = 10;
[ih0,iw0,it0] = ind2sub([H,W,T],lblxi{evtSel});
rgh = max(min(ih0)-gaphw,1):min(max(ih0)+gaphw,H);
rgw = max(min(iw0)-gaphw,1):min(max(iw0)+gaphw,W);
rgt = max((min(it0)-2),1):min((max(it0)+2),T);
H0 = numel(rgh);
W0 = numel(rgw);
T0 = numel(rgt);
m0 = mapx(rgh,rgw,rgt);
df0 = df(rgh,rgw,rgt);

% !! imputation
m0Other = m0>0 & m0~=evtSel;
df0(m0Other) = 0;
vMap0 = sum(m0,3)>0;


%% emphasize on the bright parts
df0m = movmean(df0,5,3);
df0mMax = max(df0m,[],3);
zzshow(df0mMax)


%% super pixels based on mean intensity
spSz = 100;
nSp = round(H0*W0/spSz);
A = nanmean(df0,3);
% A = A./(nanmax(A(:))+1);
A(isnan(A)) = -100;
[L,~] = superpixels(A,nSp);
L(isnan(A) | vMap0==0) = 0;

spLst = label2idx(L);
spLst = spLst(~cellfun(@isempty,spLst));
L = zeros(H0,W0);
for ii=1:numel(spLst)
    sp0 = spLst{ii};
    L(sp0) = ii;
end

ov1 = plt.regionMapWithData(uint32(L),A,0.25); zzshow(ov1);

%% test and refererence curves
df0Vec = reshape(df0,[],T0);
nSp = numel(spLst);
tst = zeros(nSp,T0);
ref = zeros(nSp,T0);
refBase = nanmean(df0Vec,1);
for ii=1:numel(spLst)
    sp0 = spLst{ii};
    if ~isempty(sp0)
        tst0 = nanmean(df0Vec(sp0,:),1);
        k0 = std(tst0)/std(refBase);
        ref0 = refBase*k0;
        tst(ii,:) = tst0;
        ref(ii,:) = ref0;
    end
end

% idx = L(413,294);
% idx = L(419,285);
% idx = L(409,285);
% figure;plot(ref(idx,:));hold on;plot(tst(idx,:));

% graph
s = nan(nSp,1);
t = nan(nSp,1);
nPair = 0;
dh = [-1 0 1 -1 1 -1 0 1];
dw = [-1 -1 -1 0 0 1 1 1];
for ii=1:numel(spLst)
    sp0 = spLst{ii};
    [ih,iw] = ind2sub([H0,W0],sp0);
    for jj=1:numel(dh)
        ih = ih+dh(jj);
        iw = iw+dw(jj);
        idxOK = ih>0 & ih<=H0 & iw>0 & iw<=W0;
        ih = ih(idxOK);
        iw = iw(idxOK);
        ihw = sub2ind([H0,W0],ih,iw);
        if ~isempty(ihw)
            idx = L(ihw);
            idx = unique(idx(idx>ii));
            if ~isempty(idx)
                for kk=1:numel(idx)
                    nPair = nPair+1;
                    s(nPair) = ii;
                    t(nPair) = idx(kk);                    
                end
            end
        end
    end    
end


%% gtw
nVar = opts.varEst/4;
smoBase = 0.01;
maxStp = 15;
[ ss,ee,gInfo ] = gtw.buildGTWGraph( ref, tst, s, t, smoBase, maxStp, nVar);
[~, labels1] = aoIBFS.graphCutMex(ss,ee);
path0 = gtw.label2path4Aosokin( labels1, ee, ss, gInfo );

% warped curves
pathCell = cell(H0,W0);
vMap1 = zeros(H0,W0);
for ii=1:nSp
    sp0 = spLst{ii};
    [ih,iw] = ind2sub([H0,W0],sp0);
    ih0 = round(mean(ih));
    iw0 = round(mean(iw));
    pathCell{ih0,iw0} = path0{ii};
    vMap1(ih0,iw0) = 1;
end
datWarp = gtw.warpRef2Tst(pathCell,refBase/max(refBase(:)),vMap1,[H0,W0,T0]);

zzshow(datWarp)

% v = VideoWriter('newfile.avi','Motion JPEG AVI');
% v.FrameRate = 5;
% open(v);
% for tt=1:T0
%     writeVideo(v,datWarp(:,:,tt));
% end
% close(v);

% ov1 = plt.regionMapWithData(uint32(L),A,0.25); 
% tmp = ov1(:,:,1);
% tmp(vMap1>0) = 255;
% ov1(:,:,1) = tmp;
% zzshow(ov1);

%% interpolation for reconstructed data
datWarp1 = zeros(H0,W0,T0);
for tt=1:T0
    
    
end





























