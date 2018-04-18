function [arLst,dActVox] = getAr(dF,opts)
% candidate regions
% TODO: multi-scale

T = size(dF,3);
dActVox = false(size(dF));
dActVoxDi = false(size(dF));
% thrSeed = opts.thrARScl;
for tt=1:T
    tmp = imgaussfilt(dF(:,:,tt),opts.smoXY);
    tmp = bwareaopen(tmp>opts.thrARScl*sqrt(opts.varEst),4,4);
    dActVox(:,:,tt) = tmp>0;
    tmp1 = bwareaopen(tmp>opts.thrARScl*sqrt(opts.varEst),4,4);
    tmp2 = imdilate(tmp>0,strel('square',10));
    tmp12 = bwareaopen(tmp1&tmp2,opts.minSize,4);
    %tmp12 = imfill(tmp12,'holes');
    dActVoxDi(:,:,tt) = tmp12;
end
% dL = bwlabeln(dActVoxDi);
arLst = bwconncomp(dActVoxDi);
arLst = arLst.PixelIdxList;

end