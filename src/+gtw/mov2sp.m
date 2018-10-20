function [spLst,spSeedVec,spSzVec,spStd] = mov2sp(dF,validMap,spSz,s00)
% mov2sp turn dF map to super pixels

[H,W,~] = size(dF);

dFAvg = nanmean(dF,3);
dFAvg = imgaussfilt(dFAvg,1);
dFAvg(validMap==0) = -100;

nSp = round(H*W/spSz);

L = superpixels(dFAvg,nSp,'Compactness',10);

L(validMap==0) = 0;
lst = label2idx(L);
spLst = lst(cellfun(@numel,lst)>0);
spSzVec = cellfun(@numel,spLst);
spStd = s00./sqrt(spSzVec);
spSeedVec = zeros(numel(spLst),1);
for ii=1:numel(spLst)
    pix0 = spLst{ii};
    [ih,iw] = ind2sub([H,W],pix0);
    ih0 = round(mean(ih));
    iw0 = round(mean(iw));
    spSeedVec(ii) = sub2ind([H,W],ih0,iw0);
end

end









