function [datWarpInt,rMapAvg,datWarp,seedMap1] = anaGridPath(path0,spLst,dfm,vMap0,intMap,spSz,refBase)
% anaGridPath extract information from GTW path on a grid structure

[H0,W0] = size(dfm);
T1 = numel(refBase);
nSp = numel(spLst);

% warped curves
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
refBase1 = refBase;
refBase1 = refBase1/max(refBase1(:));
datWarp = gtw.warpRef2Tst(pathCell,refBase1,vMap1,[H0,W0,T1]);

% k nearest neighbors weighted average interpolation
dfm = medfilt2(dfm);

nPix = H0*W0;
kDist = 1;
kInt = 20;  % weight for intensity distance
nNeib = 5;
% gaphw = 10;
pNeib = nan(nPix,nNeib);  % neighbor seed index of each pixel
pWeit = nan(nPix,nNeib);  % weight to neighbor seeds
[sh,sw] = find(seedMap1>0);
pixMap = zeros(H0,W0);
pixMap(:) = 1:nPix;
for ii=1:numel(sh)
    %if mod(ii,10000)==0; fprintf('%d\n',ii); end
    sh0 = sh(ii);
    sw0 = sw(ii);
    
    lvl0 = max(intMap(sh0,sw0),1);
    sz0 = spSz(lvl0);
    gaphw = ceil(sqrt(sz0));
    
    % pixels near a seed
    rgh = max(sh0-gaphw,1):min(sh0+gaphw,H0);
    rgw = max(sw0-gaphw,1):min(sw0+gaphw,W0);    
    pix0 = reshape(pixMap(rgh,rgw),[],1);
    [pixh,pixw] = ind2sub([H0,W0],pix0);
    
    % distances
    dEuc = sqrt((sh0-pixh).^2+(sw0-pixw).^2);
    dInt = abs(dfm(sh0,sw0) - dfm(pix0));
    dWeit = 1./max(kDist*dEuc + kInt*dInt,0.00001);
    
    % assign seed to pixels
    seedPos = pixMap(sh0,sw0);
    for jj=1:numel(pix0)
        pix00 = pix0(jj);
        nx = pNeib(pix00,:);
        wx = pWeit(pix00,:);
        loc00 = find(isnan(nx),1);
        if isempty(loc00)
            [xMin,ixMin] = nanmin(wx);
            if xMin<dWeit(jj)
                nx(ixMin) = seedPos;
                wx(ixMin) = dWeit(jj);
            end
        else
            nx(loc00) = seedPos;
            wx(loc00) = dWeit(jj);
        end
        pNeib(pix00,:) = nx;
        pWeit(pix00,:) = wx;
    end
end
pNeib(isnan(pNeib)) = 1;
pWeit(isnan(pWeit)) = 0;

% interpolation
datWarpInt = zeros(H0*W0,T1);
% [y0,x0] = find(seedMap1>0);
% yx = sub2ind([H0,W0],y0,x0);
pixSel = find(vMap0>0);
pNeib1 = pNeib(pixSel,:);
pWeit1 = pWeit(pixSel,:);
pWeit1Sum = sum(pWeit1,2);
% [xq,yq] = meshgrid(1:W0,1:H0);
for tt=1:T1
    %if mod(tt,10)==0; fprintf('Interpolate %d\n',tt); end
    d0 = datWarp(:,:,tt);
    d0(isnan(d0)) = 0;
    %v0 = d0(yx);
    datWarpInt(pixSel,tt) = sum(d0(pNeib1).*pWeit1,2)./pWeit1Sum;
    %vq = griddata(x0,y0,v0,xq,yq);
    %vq(vMap0==0) = 0;
    %datWarpInt(:,:,tt) = vq;
end
datWarpInt = reshape(datWarpInt,H0,W0,T1);

% zzshow(datWarp)
% zzshow(datWarpInt)

% rising time map
thrx = 0.2:0.1:0.8;
rMap = nan(H0,W0,numel(thrx));
for hh=1:H0
    for ww=1:W0
        if vMap0(hh,ww)>0
            x0 = squeeze(datWarpInt(hh,ww,:));
            for ii=1:numel(thrx)
                x0i = x0>thrx(ii);
                ix = find(x0i>0,1);
                if ~isempty(ix)
                    rMap(hh,ww,ii) = ix;
                end
            end
        end
    end
end
rMapAvg = nanmean(rMap,3);

% figure;imagesc(rMapAvg,'AlphaData',~isnan(rMapAvg));colorbar
% figure;imagesc(vq,'AlphaData',~isnan(vq));colorbar

end



