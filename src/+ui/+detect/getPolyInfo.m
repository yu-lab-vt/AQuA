function [polyMask,polyCenter,polyBorder,polyAvgDist] = getPolyInfo(polyLst,sz)
nPoly = length(polyLst);
polyMask = cell(nPoly,1);
polyCenter = nan(nPoly,2);
polyBorder = cell(nPoly,1);  % boundary pixels
polyAvgDist = nan(nPoly,1);
for ii=1:nPoly
    poly0 = polyLst{ii};
    if ~isempty(poly0)
        msk = zeros(sz(1),sz(2));
        msk(poly0) = 1;
        cc = regionprops(msk,'Centroid');
        rCentroid = cc.Centroid;  % first item is X, second is Y, later same as dimension order
        polyCenter(ii,:) = rCentroid;
        polyMask{ii} = msk;
        mskBd = bwperim(msk);
        [iy,ix] = find(mskBd>0);
        polyBorder{ii} = [ix,iy];
        polyAvgDist(ii) = max(round(median(sqrt((rCentroid(1)-ix).^2 + (rCentroid(2)-iy).^2))),1);
    end
end
end