function [ iL,iH,vid ] = adjustBrightness( vid,doAdjust,mskIn )
%adjustBrightness auto adjustment of brightness

[H,W,T] = size(vid);

if ~exist('mskIn','var')
    mskIn = ones(H,W);
end

% use a representative part of the video
nCnt = 20;
gapx = ceil(T/nCnt);
vidx = vid(:,:,1:gapx:end);

for ii=1:size(vidx,3)
    tmp = vidx(:,:,ii);
    tmp(mskIn==0) = mean(tmp(mskIn==1));
    vidx(:,:,ii) = tmp;
end

T1 = size(vidx,3);

x = sort(vidx(:));
iL = x(round(H*W*T1*0.0005));
iH = x(round(H*W*T1*0.9995));
if doAdjust
    vid = (vid-iL)/(iH-iL);
end

end

