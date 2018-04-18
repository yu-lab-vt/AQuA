function [dat,datSmo,dL,arLst,lmLoc,lmLocR] = actTop(dat,dF,opts)

T = size(dat,3);

datSmo = zeros(size(dat),'single');
% datSmo1 = zeros(size(dat));
for tt=1:T
    datSmo(:,:,tt) = imgaussfilt(dat(:,:,tt),2);
    dat(:,:,tt) = imgaussfilt(dat(:,:,tt),opts.smoXY);
end
% if opts.usePG>0
%     datOrg = dat.^2*2;
% else
%     datOrg = dat;
% end
% dat = datSmo1;

% get seeds
[arLst,dActVox] = burst.getAr(dF,opts);
fsz = [1 1 0.5];  % smoothing for seed detection
% fsz = [0.5 0.5 0.5];
[lmLoc,lmLocR] = burst.getLmAll(dat,arLst,dActVox,fsz);

dL = zeros(size(dat),'logical');
for nn=1:numel(arLst)
    dL(arLst{nn}) = true;
end

end