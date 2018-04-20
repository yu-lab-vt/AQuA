% check residual signal
% [df0ip,dfm,intMap,spSz,spLst] = gtw.dfMov2sp(df0,m0,vMap0,nnx,riseOnly,varEst);

thrZ = 0;
[df0ip,dfm,spSz,spLst,spMap] = gtw.dfMov2spSingleThr(df0,m0,seSel,varEst,thrZ);

ov1 = plt.regionMapWithData(uint32(spMap),spMap*0,0.3); zzshow(ov1);

[ref,tst,refBase,s,t,txx,spLst] = gtw.sp2graph(df0ip,vMap0,spLst,0,varEst);

%% gtw alignment and extract information
smoBase = 0.5;
varEstSp = opts.varEst/sqrt(spSz);
maxStp1 = max(min(maxStp,ceil(numel(refBase)/2)),2);
[ ss,ee,gInfo ] = gtw.buildGTWGraph( ref, tst, s, t, smoBase, maxStp1, varEstSp);
[~, labels1] = aoIBFS.graphCutMex(ss,ee);
path0 = gtw.label2path4Aosokin( labels1, ee, ss, gInfo );

% intMap = ones(H0,W0);
% [datWarpInt,rMapAvg,datWarp,seedMap1] = gtw.anaGridPath(path0,spLst,dfm,vMap0,intMap,spSz,refBase);

%% warp curves
[H0,W0] = size(dfm);
T1 = numel(refBase);
nSp = numel(spLst);
pathCell = cell(H0,W0);
vMap1 = zeros(H0,W0);
seedMap1 = zeros(H0,W0);
for ii=1:nSp
    sp0 = spLst{ii};
    [ih,iw] = ind2sub([H0,W0],sp0);
    ih0 = round(mean(ih));
    iw0 = round(mean(iw));
    pathCell{ih0,iw0} = path0{ii};
    vMap1(ih0,iw0) = 1;
    seedMap1(ih0,iw0) = ii;
end
refBase1 = refBase/max(refBase(:));
datWarp = gtw.warpRef2Tst(pathCell,refBase1,vMap1,[H0,W0,T1]);

%% interpolation
datWarpInt = zeros(H0,W0,T1);
[y0,x0] = find(seedMap1>0);
yx = sub2ind([H0,W0],y0,x0);
[xq,yq] = meshgrid(1:W0,1:H0);
for tt=1:T1
    if mod(tt,10)==0; fprintf('Interpolate %d\n',tt); end
    d0 = datWarp(:,:,tt);
    d0(isnan(d0)) = 0;
    v0 = d0(yx);
    vq = griddata(x0,y0,v0,xq,yq,'natural');
    %vq(vMap0==0) = 0;
    datWarpInt(:,:,tt) = vq;
end





