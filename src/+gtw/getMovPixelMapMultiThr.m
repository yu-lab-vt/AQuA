function tMapMT = getMovPixelMapMultiThr(dFx,Sx,thrVec,s00)
% getMovPixelMapMultiThr split pixel map according to intensity thresholds

[H0,W0,~] = size(dFx);

Mx = sum(Sx,3)>0;
SxMin = nanmin(Sx(:));
Sx(Sx>0) = Sx(Sx>0)-SxMin+1;

szVec = zeros(size(thrVec))+4;
tMapMT = zeros(H0,W0,numel(thrVec));
for ii=1:numel(thrVec)    
    dFxHi = dFx>thrVec(ii)*s00;
    dFxHi(Sx==0) = 0;
    dFxHi = bwareaopen(dFxHi,szVec(ii),8);
    M0 = 1*(sum(dFxHi,3)>0 & Mx);
    M0(M0==0) = nan;
    tMapMT(:,:,ii) = M0;
end

end


