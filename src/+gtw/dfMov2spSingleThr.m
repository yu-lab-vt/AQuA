function [df0ip,dfm,spSz,spLst,spMap,seedMap] = dfMov2spSingleThr(df0,m0,seSel,varEst,thrZ)
% dfMov2sp convert df movie to super pixels emphasizing bright parts
% df0 may contain missing values

[H0,W0,T0] = size(df0);

df0(m0>0 & m0~=seSel) = nan;
df0ip = gtw.imputeMov(df0);
dfm = nanmean(df0ip,3);

s00 = sqrt(varEst);
Sx = 1*(m0==seSel);
tMapMT = gtw.getMovPixelMapMultiThr(df0ip,Sx,thrZ,s00);
tMapMT = squeeze(tMapMT);
tMapMT(isnan(tMapMT)) = 0;

% super pixels that has signals
seedMap = zeros(H0,W0);
nPix = sum(tMapMT(:)>0);
if nPix>0
    % super pixel sizes and numbers
    nNodeUB = round(100*100*30/T0);
    spSz = max(nPix/nNodeUB,8);
    nx = round(H0*W0/spSz);
    
    % super pixels
    spMap = zeros(H0,W0);    
    %dfmMed = imgaussfilt(dfm,20);
    A = ones(H0,W0);
    L0 = superpixels(A,nx);
    
    % within tMapMT
    spLst0 = label2idx(L0);    
    nSp = 0;
    for jj=1:numel(spLst0)
        pix00 = spLst0{jj};
        [h0,w0] = ind2sub([H0,W0],pix00);
        if sum(tMapMT(pix00))>0
            nSp = nSp + 1;
            spMap(pix00) = nSp;
            seedMap(round(mean(h0)),round(mean(w0))) = nSp;
        end
    end
    spLst = label2idx(spMap);
else
    spSz = 0;
    spLst = [];
end

% ov1 = plt.regionMapWithData(uint32(spMap),spMap*0,0.3); zzshow(ov1);

end



