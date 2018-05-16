function [lmLoc,lmVal,lm3Idx] = getLocalMax3D(dat,mskST,mskSig,fsz)
% getLocalMax3D find local maximum after smoothing

if ~exist('mskST','var')
    mskST = ones(size(dat));
end

[H,W,T] = size(dat);
datV = zeros(size(dat));
gap = 3;
for tt=1:T
    datV(:,:,tt) = std(dat(:,:,max(tt-gap,1):min(tt+gap,T)),[],3);
end
datSmo1 = imgaussfilt3(dat,fsz);

lm3 = imregionalmax(datSmo1);
lm3(:,:,1) = zeros(H,W);
lm3(:,:,end) = zeros(H,W);
tmp = lm3(mskST>0);
if sum(tmp(:))>0
    lm3(mskST==0) = 0;
else
    lm3(mskSig==0) = 0;
end

lm3Idx = 1*lm3; lm3Idx(lm3>0) = 1:sum(lm3(:)>0);

lmLoc = find(lm3>0);
lmVal = datV(lm3>0);
end