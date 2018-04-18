function seedInfo = initSeed( validMap,cx,seedGap )
%INITSEED Initialize the seed
% Either use correlation map or specify seed location

[H,W] = size(validMap);

if length(cx(:))==1
    idx = cx;
    cmax = 1;
else
    tmp = cx;
    tmp(validMap==0) = 0;
    [cmax,idx] = max(tmp(:));  % seed position
end

[ihSeed,iwSeed] = ind2sub(size(validMap),idx);

rgx = ihSeed-seedGap:ihSeed+seedGap;
rgy = iwSeed-seedGap:iwSeed+seedGap;
rgx = rgx(rgx>0 & rgx<=H);
rgy = rgy(rgy>0 & rgy<=W);

seedInfo = [];
seedInfo.idx = idx;
seedInfo.ih = ihSeed;
seedInfo.iw = iwSeed;
seedInfo.rgx = rgx;
seedInfo.rgy = rgy;
seedInfo.cmax = cmax;

end
