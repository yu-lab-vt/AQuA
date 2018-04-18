function [resLst,vLst,iLst,mskLst,dlyOrder] = alignEvent(dat,datSmo,lblMapF,datMsk,opts)
% alignEvent Re-align pixels in each event

[H,W,T] = size(dat);
gapt = 5;

if opts.usePG
    dat = dat.^2;
    datSmo = datSmo.^2;
    datSmoBase = min(movmean(datSmo,opts.movAvgWin,3),[],3);
    dat = dat - datSmoBase;
    datSmo = datSmo - datSmoBase;
    opts.gtwSmo = opts.evtGtwSmo;
else
    datSmoBase = min(movmean(datSmo,opts.movAvgWin,3),[],3);
    dat = dat - datSmoBase;
    datSmo = datSmo - datSmoBase;
end

voxLst = label2idx(lblMapF);
nEvt = numel(voxLst);

% early events first. Later events allowed to eat the tail of previous
tVec = Inf(nEvt,1);
for nn=1:nEvt
    vox = voxLst{nn};
    if ~isempty(vox)
        [~,~,it0] = ind2sub([H,W,T],vox);
        tVec(nn) = min(it0);
    end
end
[~,dlyOrder] = sort(tVec,'ascend');

%% fill holes
for nn=1:nEvt
    if mod(nn,100)==0; fprintf('%d/%d\n',nn,nEvt); end
    vox = voxLst{dlyOrder(nn)};
    
    % avoid voxels outside mask
    voxGood = datMsk(vox)>0;
    vox = vox(voxGood);    
    if isempty(vox)
        continue
    end
    
    % spatial boundary of this event
    [ih1,iw1,~] = ind2sub([H,W,T],vox);
    rgH1 = max(min(ih1)-1,1):min(max(ih1)+1,H);
    rgW1 = max(min(iw1)-1,1):min(max(iw1)+1,W);
    H1 = numel(rgH1);
    W1 = numel(rgW1);
    ih1a = ih1 - min(rgH1) + 1;
    iw1a = iw1 - min(rgW1) + 1;

    % spatial valid map
    validMap1 = zeros(H1,W1);
    ihw1 = unique(sub2ind([H1,W1],ih1a,iw1a));
    validMap1(ihw1) = 1;
    validMap2 = imfill(validMap1,'holes');    

    % label to help exclude other events
    lbl1 = lblMapF(rgH1,rgW1,:);
    msk1 = datMsk(rgH1,rgW1,:);
    idxNewPix = find(validMap2-validMap1>0);
    [ihx,iwx] = find(validMap1>0);
    if ~isempty(idxNewPix)
        for ii=1:numel(idxNewPix)
            [ih00,iw00] = ind2sub([H1,W1],idxNewPix(ii));
            [~,ixMin] = min((ih00-ihx).^2+(iw00-iwx).^2);
            lbl00 = lbl1(ihx(ixMin),iwx(ixMin),:);
            t0 = find(lbl00==dlyOrder(nn),1);
            t1 = find(lbl00==dlyOrder(nn),1,'last');
            lbl1(ih00,iw00,t0:t1) = dlyOrder(nn);
            msk1(ih00,iw00,t0:t1) = dlyOrder(nn);
        end
    end
    lblMapF(rgH1,rgW1,:) = lbl1;    
    datMsk(rgH1,rgW1,:) = msk1;
end
voxLst = label2idx(lblMapF);

%% crop and extend events
vLst = cell(nEvt,1);
dLst = cell(nEvt,1);
iLst = cell(nEvt,3);
mskLst = cell(nEvt,1);
for nn=1:nEvt
    if mod(nn,100)==0; fprintf('%d/%d\n',nn,nEvt); end
    vox = voxLst{dlyOrder(nn)};
    
    % avoid voxels outside mask
    voxGood = datMsk(vox)>0;
    vox = vox(voxGood);    
    if isempty(vox)
        continue
    end
    
    % spatial boundary of this event
    [ih1,iw1,it1] = ind2sub([H,W,T],vox);
    rgH1 = max(min(ih1)-1,1):min(max(ih1)+1,H);
    rgW1 = max(min(iw1)-1,1):min(max(iw1)+1,W);
    H1 = numel(rgH1);
    W1 = numel(rgW1);
    ih1a = ih1 - min(rgH1) + 1;
    iw1a = iw1 - min(rgW1) + 1;
        
    % spatial valid map
    validMap1 = zeros(H1,W1);
    ihw1 = unique(sub2ind([H1,W1],ih1a,iw1a));
    validMap1(ihw1) = 1;
    
    % label to help exclude other events
    lbl1 = lblMapF(rgH1,rgW1,:);
    lbl1Vec = reshape(lbl1,[],T);
    
    % spatial crop of data
    dat1 = dat(rgH1,rgW1,:);
    dat1Vec = reshape(dat1,[],T);
    dat1VecMask = dat1Vec*0;       
    
    % use smoothed data to find minimum value
    dat1Smo = datSmo(rgH1,rgW1,:);    
    dat1SmoVec = reshape(dat1Smo,[],T);
    
    % for each pixel, replace time points from other events by baseline
    tBegin = T;
    tEnd = 1;
    for ii=1:size(dat1SmoVec,1)
        if validMap1(ii)==0
            continue
        end
        lblOnePix = lbl1Vec(ii,:);
        dat1SmoOnePix = dat1SmoVec(ii,:);
        dat1OnePix = dat1Vec(ii,:);
        dat1OnePixMask = dat1VecMask(ii,:);
        
        % time for previous or next events
        t0 = find(lblOnePix==dlyOrder(nn),1);
        t1 = find(lblOnePix==dlyOrder(nn),1,'last');
        lblOnePix(t0:t1) = 0;
        t0p = find(lblOnePix(1:t0)>0,1,'last');
        if isempty(t0p)
            t0p = 1;
        end
        dt1p = find(lblOnePix(t1:end)>0,1);
        if isempty(dt1p)
            t1p = T;
        else
            t1p = t1+dt1p-1;
        end
        
        % lowest point between events
        [xMin0,dt0a] = min(dat1SmoOnePix(t0p:t0));
        [xMin1,dt1a] = min(dat1SmoOnePix(t1:t1p));
        t0a = t0p + dt0a - 1;
        t1a = dt1a + t1 - 1;
        
        % signal low enough
        t0b = t0a; t1b = t1a;
        
        % impute time points potentially from other events
        dat1OnePixMask(1:t0b) = 1;
        dat1OnePixMask(t1b:end) = 1;
        dat1OnePix(1:t0b) = xMin0+randn(1,t0b)*sqrt(opts.varEst);
        dat1OnePix(t1b:end) = xMin1+randn(1,T-t1b+1)*sqrt(opts.varEst);
        dat1Vec(ii,:) = dat1OnePix;
        dat1VecMask(ii,:) = dat1OnePixMask;
        
        if ~isempty(t0b)
            tBegin = min(tBegin,t0b);
        end
        if ~isempty(t1b)
            tEnd = max(tEnd,t1b);
        end
    end
    tBegin = max(tBegin,max(min(it1)-gapt,1));
    tEnd = min(tEnd,min(max(it1)+gapt,T));
    
    % temporal cropping
    rgT = tBegin:tEnd;
    if numel(rgT)<3  % in case signal too short
        rgT = max(tBegin-2,1):min(tEnd+2,T);
    end
    dat1a = reshape(dat1Vec,H1,W1,T);
    dat1a = dat1a(:,:,rgT);    
    
    dat1aMask = reshape(dat1VecMask,H1,W1,T);
    dat1aMask = dat1aMask(:,:,rgT);    
    
    vLst{nn} = validMap1;
    dLst{nn} = dat1a;    
    iLst(nn,:) = {rgH1,rgW1,rgT};
    mskLst{nn} = find(dat1aMask>0);
end

%% alignment
resLst = cell(nEvt,1);
opts.maxStp = opts.evtMaxStp;
opts.blkGapSeed = 100;

getWarn = 1;
lastwarn('');
idxWarn = zeros(nEvt,1);
% for nn=1:nEvt
parfor nn=1:nEvt  % !! will this use too much memory?
    fprintf('%d\n',nn)
    d0 = dLst{nn};
    v0 = vLst{nn};
    if isempty(d0)
        continue
    end
    resLst{nn} = burst.fitOnCr1(d0,opts,v0);
    [warnMsg, ~] = lastwarn;
    if ~isempty(warnMsg) && getWarn>0
        idxWarn(nn) = 1;        
    end
end

if sum(idxWarn)>0
    d0x = dLst(idxWarn>0);
    v0x = vLst(idxWarn>0);
    save('fitting_warning.mat','d0x','opts','v0x');
end

end






