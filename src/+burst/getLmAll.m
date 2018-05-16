function [lmLoc,lmVal] = getLmAll(dat,arLst,dActVox,fsz)
% detect all local maximums in a movie

gaph = 3;
gapt = 3;
[H,W,T] = size(dat);
% arLst = label2idx(dL);
nAR = numel(arLst);

% detect in active region only
lmAll = zeros(size(dat),'logical');
for ii=1:nAR
    if mod(ii,1000)==0; fprintf('%d/%d\n',ii,nAR); end
    kk = ii;
    pix0 = arLst{kk};
    if isempty(pix0)
        continue
    end
    [ih,iw,it] = ind2sub([H,W,T],pix0);
    
    rgH = max(min(ih)-gaph,1):min(max(ih)+gaph,H);
    rgW = max(min(iw)-gaph,1):min(max(iw)+gaph,W);
    rgT = max(min(it)-gapt,1):min(max(it)+gapt,T);
    
    dInST = dat(rgH,rgW,rgT);
    ih1 = ih - min(rgH) + 1;
    iw1 = iw - min(rgW) + 1;
    it1 = it - min(rgT) + 1;
    pix0a = sub2ind(size(dInST),ih1,iw1,it1);
    mskST = false(size(dInST));
    mskST(pix0a) = true;
    mskSTSeed = dActVox(rgH,rgW,rgT);
    mskSTSeed = mskST & mskSTSeed;    
    [~,~,lm3Idx] = burst.getLocalMax3D(dInST,mskSTSeed,mskST,fsz);    
    lmAll(rgH,rgW,rgT) = max(lmAll(rgH,rgW,rgT),lm3Idx>0);    
end
lmLoc = find(lmAll>0);
lmVal = dat(lmLoc);
[lmVal,ix] = sort(lmVal,'descend');
lmLoc = lmLoc(ix);

end






