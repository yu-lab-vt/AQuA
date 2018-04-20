function res = detectGrowSp(datIn,res,opts)
%detectGrowSp extend a super voxel by one step
%
% Needed for stage 0 (stg==0)
%   res.charxIn     : reference curve
%   res.tw          : time window object
%   res.iSeed       : 3D index of seed location
%   res.stg         : 0, init stage. 1, extending stage
% Also needed for stage 1 (stg==1)
%   res.fiux        : list of index in 2D for pixels in this event
%   res.twMap       : time window, N by 4
%   res.pixBad      : bad pixels index in 2D

[H,W,~] = size(datIn);
minPixZ = opts.thrExtZ;

% crop data to reduce cost
tw = res.tw;
tx0 = tw.t0;
tx1 = tw.t1;
tw.t0 = tw.t0-tx0+1;
tw.t1 = tw.t1-tx0+1;
tw.t0a = tw.t0a-tx0+1;
tw.t1a = tw.t1a-tx0+1;
tw.tPeak = tw.tPeak-tx0+1;

% data
T = tx1-tx0+1;
dat = datIn(:,:,tx0:tx1);
datVec = reshape(dat,[],T);

% seed loc
[ihSeed,iwSeed,~] = ind2sub(res.MovSz,res.iSeed);
ihSeed = ihSeed-min(res.rgH)+1;
iwSeed = iwSeed-min(res.rgW)+1;
ihwSeed = sub2ind([H,W],ihSeed,iwSeed);

% % reference curve
% charxIn = res.charxIn(tx0:tx1);
% xx = charxIn(tw.t0:tw.t1);
% if res.stg==0
%     r1 = imgaussfilt(xx,1);
%     charxIn(tw.t0:tw.t1) = r1;
% end
% xref = nan(1,numel(charxIn));  % missing value will be zero data term cost in GTW
% xref(tw.t0:tw.t1) = charxIn(tw.t0:tw.t1);
% xref = xref - nanmin(xref);
% xref = xref/nanmax(xref);

% init
fiux = zeros(H,W);  % included pixels
pixBad = zeros(H,W);  % weak pixels and excluded pixels
twMap = zeros(H*W,5);  % time window for each pixel: start, stop, 50% rise, 50% fall, peak time
if res.stg==1
    fiux(res.fiux) = 1;
    pixBad(res.pixBad) = 1;
    twMap(res.fiux,:) = res.twMap-tx0+1;
else
    fiux(ihSeed,iwSeed) = 1;
    fiux(pixBad>0) = 0;
end
twMap(ihwSeed,:) = [tw.t0,tw.t1,tw.t0a,tw.t1a,tw.tPeak];

% choose pixels for checking
pixBadPre = pixBad;
[validMap,twMap] = burst.getValidMap(twMap,fiux,pixBadPre,res.stg==0);
% pix0 = find(fiux>0);
pix1 = find(validMap>0);
nPix = numel(pix1);
if sum(validMap(:))>0
    %     if res.stg==0
    %         sz0 = ones(nPix,1)+100;
    %         zBase = 0;
    %     else
    
    sz0 = zeros(nPix,1);  % score for each new pixel
    s0 = sqrt(opts.varEst);
    
%     x0 = datVec(ihwSeed,tw.t0);
%     x1 = datVec(ihwSeed,tw.t1);
%     xp = datVec(ihwSeed,tw.tPeak);
%     szSeed = min((xp-x0)/s0,(xp-x1)/s0);
%     %         if szSeed<1.5
%     %             keyboard
%     %         end
%     zBase = min(max(szSeed,0.5),minPixZ);
    
    for ii=1:nPix
        x0 = datVec(pix1(ii),tw.t0);
        x1 = datVec(pix1(ii),tw.t1);
        xp = datVec(pix1(ii),tw.tPeak);
        sz0(ii) = min((xp-x0)/s0,(xp-x1)/s0);
    end
    
    %         % current significance
    %         s0m = s0/sqrt(nPix);
    %         x0 = datVec(pix0,tw.t0);
    %         x1 = datVec(pix0,tw.t1);
    %         xp = datVec(pix0,tw.tPeak);
    %         zBase = min(mean(xp-x0)/s0m,mean(xp-x1)/s0m);
    %
    %         % choose pixels that makes the region more significant
    %         s0m = s0/sqrt(nPix+1);
    %         for ii=1:nPix
    %             pix0a = [pix0;pix1(ii)];
    %             x0 = datVec(pix0a,tw.t0);
    %             x1 = datVec(pix0a,tw.t1);
    %             xp = datVec(pix0a,tw.tPeak);
    %             sz0(ii) = min(mean(xp-x0)/s0m,mean(xp-x1)/s0m);
    %         end
    %     end
    
    isBad = 1*(sz0<minPixZ);
    %isBad = 1*(sz0<zBase);
    pixBad(validMap>0) = isBad;
    fiux(validMap>0 & pixBad==0) = 1;
end

% output
fiuxIdx = 1*fiux;
fiuxIdx(fiux>0) = 1:sum(fiux(:));
if isfield(res,'fiux')
    fiuxIdx(res.fiux) = 0;
end
res.pixNew = fiuxIdx(fiuxIdx>0);  % index of newly added pixels
res.fiux = find(fiux>0);  % index of all added pixels
res.twMap = twMap(fiux>0,:)+tx0-1;  % time windows for all added pixels
res.pixBad = find(pixBad>0);
res.stg=1;

end

















