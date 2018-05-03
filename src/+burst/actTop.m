function [arLst,lmLoc] = actTop(dat,dF,opts,evtSpatialMask,ff)

[H,W,~] = size(dat);

if ~exist('evtSpatialMask','var')
    evtSpatialMask = ones(H,W);
end

% get seeds
[arLst,dActVox] = burst.getAr(dF,opts,evtSpatialMask);
if exist('ff','var')
    waitbar(0.5,ff);
end
fsz = [1 1 0.5];  % smoothing for seed detection
% fsz = [0.5 0.5 0.5];
lmLoc = burst.getLmAll(dat,arLst,dActVox,fsz);
if exist('ff','var')
    waitbar(1,ff);
end

end