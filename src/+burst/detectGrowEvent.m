function res = detectGrowEvent(datIn,datInSmo,res,opts,maxGrow,validMapIn)
%DETECTSINGLEEVENT Detect one event
%   Start fitting from seed and region growing
%   Continue fitting when 'res' is given
%
%   Needed for stage 0 (stg==0)
%   res.charxIn     : reference curve
%   res.tw          : time window object
%   res.iSeed       : 3D index of seed location
%   res.stg         : 0, init stage. 1, extending stage
% Also needed for stage 1 (stg==1)
%   res.fiux        : list of index in 2D for pixels in this event
%   res.twMap       : time window, N by 4
%   res.pixBad      : bad pixels index in 2D
%   res.bdsCell     : cell array, N by 1, current fitting results for pixels in fiux
%
% bdsCell is stored in cropped coordinates, all others in original

[H,W,Tin] = size(datIn);

% crop data to reduce cost
tw = res.tw;
tx0 = max(tw.t0 - opts.maxStp,1);
tx1 = min(tw.t1 + opts.maxStp,Tin);
tw.t0 = tw.t0-tx0+1;
tw.t1 = tw.t1-tx0+1;
tw.t0a = tw.t0a-tx0+1;
tw.t1a = tw.t1a-tx0+1;
tw.tPeak = tw.tPeak-tx0+1;
T = tx1-tx0+1;
dat = datIn(:,:,tx0:tx1);
datSmo = datInSmo(:,:,tx0:tx1);

% denoise curve
charxIn = res.charxIn(tx0:tx1);
xx = charxIn(tw.t0:tw.t1);
if res.stg==0
    r1 = imgaussfilt(xx,1);
    charxIn(tw.t0:tw.t1) = r1;
end

% seed loc
[ihSeed,iwSeed,~] = ind2sub(res.MovSz,res.iSeed);
ihSeed = ihSeed-min(res.rgH)+1;
iwSeed = iwSeed-min(res.rgW)+1;
ihwSeed = sub2ind([H,W],ihSeed,iwSeed);

if ~exist('validMap','var')
    validMapIn = ones(H,W);
end

pathCell = cell(H,W);
datVec = reshape(dat,[],T);
datSmoVec = reshape(datSmo,[],T);

xref = nan(1,numel(charxIn));  % missing value will be zero data term cost in GTW
xref(tw.t0:tw.t1) = charxIn(tw.t0:tw.t1);
xref = xref - nanmin(xref);
xref = xref/nanmax(xref);

% init
fiux = zeros(H,W);  % included pixels
sz = zeros(H,W);  % z score map
pixBad = zeros(H,W);  % weak pixels and excluded pixels
twMap = zeros(H*W,5);  % time window for each pixel: start, stop, 50% rise, 50% fall
bds = ones(H,W);  % pixels that need boundary constraints
bdsCell = cell(H,W);  % warping functions for boundary pixels

tst2RefVec = nan(H*W,T);
if res.stg==1
    fiux(res.fiux) = 1;
    sz(res.fiux) = res.sz;
    pixBad(res.pixBad) = 1;
    twMap(res.fiux,:) = res.twMap-tx0+1;
    bdsCell(res.fiux) = res.bdsCell;
else
    fiux(ihSeed,iwSeed) = 1;
    fiux(pixBad>0) = 0;
    ref2TstVec = nan(H*W,T);
    ref2TstVec(ihwSeed,:) = xref;
end
twMap(ihwSeed,:) = [tw.t0,tw.t1,tw.t0a,tw.t1a,tw.tPeak];

%% grow by several loops
minPixZ = opts.thrExtZ;
for nGrow=1:maxGrow
    if nGrow>1
        fprintf('%d\n',nGrow)
    end
    if nGrow==1 && res.stg==0
        opts.gtwOffDiagonal = 100;
    else
        opts.gtwOffDiagonal = 0;
    end
    
    % choose pixels for fitting
    pixBadPre = pixBad;
    [validMap,twMap,~] = burst.getValidMap(twMap,fiux,pixBadPre,res.stg==0 && nGrow==1);
    validMap = validMap.*validMapIn;
    if sum(validMap(:))==0
        break
    end
    
    % initialize curves
    tst = datVec(validMap(:)>0,:);
    tstVarMap = validMap*opts.varEst;
    idx = find(validMap>0);
    peakx = zeros(numel(idx),1);
    basex = zeros(numel(idx),1);
    for ii=1:numel(idx)
        tw0 = twMap(idx(ii),:);
        basex(ii) = min(datSmoVec(idx(ii),max(tw0(1)-1,1):min(tw0(2)+1,T)));
        peakx(ii) = max(datVec(idx(ii),tw0(3):tw0(4)));
    end
    tst = tst - basex;
    rt = peakx - basex;
    refBase = xref;
    ref = rt*refBase;
    
    % fitting
    param = gtw.initGtwParam( validMap,tstVarMap,bds,bdsCell,opts );
    param.smox = 0;
    [path0,bdsCell] = gtw.getGtwPath( ref, tst, validMap, param );
    
    % warp reference curves and update time windows
    pathCell(validMap>0) = path0;
    [ref2TstVec0,twVec0,~] = gtw.warpRef2Tst(pathCell,refBase,validMap,T,twMap(ihwSeed,:),1);
    tst2RefVec0 = gtw.warpTst2Ref(pathCell,tst,validMap,1);
    
    % add pixels to FIU
    twVecPre = twMap(validMap>0,:);
    if sum(twVec0(:)<0)>0
        %fprintf('Time window fixed\n')
        %keyboard
        twVec0(twVec0<0) = twVecPre(twVec0<0);  % !! bug in GTW path
    end
    
    nPix = sum(validMap(:)>0);
    isBad = zeros(nPix,1);
    sz0 = zeros(nPix,1);
    for ii=1:nPix
        %         tw0 = twVecPre(ii,:);
        tw1 = twVec0(ii,:);
        %         if abs(tw0(3)-tw1(3))>2 || abs(tw0(4)-tw1(4))>2  % !! hard constraint
        %             isBad(ii) = 1;
        %             continue
        %         end
        %a = max(tw1(3)-1,tw1(1));
        %b = min(tw1(4)+1,tw1(2));
        a = tw1(1);
        b = tw1(2);
        y = tst(ii,a:b);
        x = ref2TstVec0(ii,a:b);
        idxGood = ~isnan(x);
        xSel = x(idxGood);
        ySel = y(idxGood);
        if numel(xSel)<3  % !! curve lenght, avoid fitting to noise
            isBad(ii) = 1;
            continue
        end
        tmp = corrcoef(xSel,ySel);
        z = stat.getFisherTrans(tmp(1,2),numel(xSel));  % !! curve similarity
        sz0(ii) = z;
    end
    
    twMap(validMap>0,:) = twVec0;
    if res.stg==0
        ref2TstVec(validMap>0,:) = ref2TstVec0;
    end
    tst2RefVec(validMap>0,:) = tst2RefVec0;
    
    isBad = 1*(sz0<minPixZ);
    pixBad(validMap>0) = isBad;
    sz(validMap>0) = sz0;
    fiux(validMap>0 & pixBad==0) = 1;
end

% fiux = bwareaopen(fiux,opts.minSize,4);

%% output
fiuxIdx = 1*fiux;
fiuxIdx(fiux>0) = 1:sum(fiux(:));
if isfield(res,'fiux')
    fiuxIdx(res.fiux) = 0;
end

res.pixNew = fiuxIdx(fiuxIdx>0);
res.fiux = find(fiux>0);
res.twMap = twMap(fiux>0,:)+tx0-1;
res.sz = sz(fiux>0);
res.szAll = sum(res.sz)/sqrt(numel(res.sz));
res.pixBad = find(pixBad>0);
res.bdsCell = bdsCell(fiux>0);
% if numel(res.pixNew)>0
%     ref1 = reshape(nanmean(tst2RefVec(fiuxIdx>0,:),1),[],1);
%     ref0 = reshape(charxIn,[],1);
%     n1 = numel(res.pixNew);
%     n0 = sum(fiux(:)>0)-n1;
%     res.charxIn = nan(1,Tin);
%     res.charxIn(tx0:tx1) = (ref1*n1+ref0*n0)/(n0+n1);
%     if sum(~isnan(res.charxIn))==0
%         res = [];
%         %         fprintf('Growing error\n')
%         %         keyboard
%     end
% end
res.stg=1;

end

















