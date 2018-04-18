function [ref,tst,refBase,tstVarMap] = initCurve1( dat,validMap,seedInfo,datScl,varEst )
%INITCURVE Initialzie test and reference curves
% Scale reference to test curves by magnitude

nTps = size(dat,3);

validIdxMap = burst.getValidIdxMap( validMap, 0 );

datVec = reshape(dat,[],nTps);
tst = datVec(validMap(:)>0,:);

tstVarMap = validMap*varEst;

rt0 = reshape(datScl(validMap>0),[],1);

% initial characteristic curve
idx1 = reshape(validIdxMap(seedInfo.rgx,seedInfo.rgy),[],1);
idx1 = idx1(idx1>0);
tstSel = tst(idx1,:);
% refBase = mean(tstSel,1);
refBase = nanmean(tstSel,1);

% denoise
r1 = refBase;
if sum(isnan(r1))==0
    r1 = imgaussfilt(r1,1);
end

% !! suppress local max
[~,ix] = max(r1);
bw = r1*0;
bw(ix) = 1;
r2 = -imimposemin(-r1,bw);
r2(ix) = r1(ix);
r2(isinf(r2)) = nan;
% refBase = r2;
refBase = imgaussfilt(r2,1);

% figure;plot(refBase);hold on;plot(r2);
% keyboard
% close all

refBase = (refBase - nanmin(refBase))/(nanmax(refBase)-nanmin(refBase));

ref = rt0*refBase;

end