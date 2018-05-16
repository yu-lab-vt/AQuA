function [arLst,dActVoxDi] = getAr(dF,opts,evtSpatialMask)
% candidate regions (legacy mode)

T = size(dF,3);
dActVoxDi = false(size(dF));
for tt=1:T
    tmp = dF(:,:,tt);
    tmp = bwareaopen(tmp>opts.thrARScl*sqrt(opts.varEst),opts.minSize,4);     
    tmp = tmp.*evtSpatialMask;
    dActVoxDi(:,:,tt) = tmp;
end
arLst = bwconncomp(dActVoxDi);
arLst = arLst.PixelIdxList;

end