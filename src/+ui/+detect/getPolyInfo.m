function [polyMask,polyCenter,polyBorder,polyAvgDist] = getPolyInfo(polyLst,sz)
nPoly = length(polyLst);
polyMask = cell(nPoly,1);
polyCenter = nan(nPoly,2);
polyBorder = cell(nPoly,1);  % boundary pixels
polyAvgDist = nan(nPoly,1);
for ii=1:nPoly
    poly0 = polyLst{ii};
    if ~isempty(poly0)
        msk = flipud(poly2mask(poly0(:,1),poly0(:,2),sz(1),sz(2)));  % need to flip it
        cc = regionprops(msk,'Centroid');
        rCentroid = cc.Centroid;
        polyCenter(ii,:) = rCentroid;
        polyMask{ii} = msk;
        mskBd = bwperim(msk);
        [ix,iy] = find(mskBd>0);
        polyBorder{ii} = [ix,iy];
        polyAvgDist(ii) = max(round(median(sqrt((rCentroid(1)-ix).^2 + (rCentroid(2)-iy).^2))),1);
    end
end
end