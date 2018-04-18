function [datc,vmapc,vmapc1,tw1Vecc,rgHc,rgWc,rgTc,rgTxc] = alignPatchShort1PrepReg(dat,datSmo,lblMapF,datMsk,voxLst,opts)
% prepare data
nRg = numel(voxLst);
[H,W,T] = size(dat);
% dlyOrder = delayOrder(voxLst,H,W,T);
dlyOrder = 1:numel(voxLst);
gaph = 10;  % larger value makes superpixel better
gapt = 10;  % 3

datVec = reshape(dat,[],T);
datSmoVec = reshape(datSmo,[],T);
lblMapFVec = reshape(lblMapF,[],T);
datMskVec = reshape(datMsk,[],T);

datc = cell(nRg,1);
vmapc = cell(nRg,1);
vmapc1 = cell(nRg,1);
tw1Vecc = cell(nRg,1);
rgTxc = cell(nRg,1);
rgHc = cell(nRg,1);
rgWc = cell(nRg,1);
rgTc = cell(nRg,1);

for nn=1:nRg
    if mod(nn,1000)==0
        fprintf('%d\n',nn)
    end
    if dlyOrder(nn)==1237
        %keyboard
    end
    vox = voxLst{dlyOrder(nn)};
    if isempty(vox)
        continue
    end
    [ih1,iw1,it1] = ind2sub([H,W,T],vox);
    ihw1 = unique(sub2ind([H,W],ih1,iw1));
    
    % overall time window due to active region
    t0 = min(it1);
    t1 = max(it1);
    msk1VecSum = sum(datMskVec(ihw1,:),1);
    t0d = find(msk1VecSum(1:t0)==0,1,'last');
    if ~isempty(t0d)
        t0 = t0d;
    end
    t1d = find(msk1VecSum(t1:end)==0,1);
    if ~isempty(t1d)
        t1 = t1d+t1-1;
    end
    rgTx = max(t0-gapt,1):min(t1+gapt,T);
    T1 = numel(rgTx);
    
    msk1Vec = datMskVec(ihw1,rgTx);
    dat1Vec = datVec(ihw1,rgTx);
    dat1SmoVec = datSmoVec(ihw1,rgTx);
    lbl1Vec = lblMapFVec(ihw1,rgTx);      
    
    % spatial window    
    rgH1 = max(min(ih1)-gaph,1):min(max(ih1)+gaph,H);
    rgW1 = max(min(iw1)-gaph,1):min(max(iw1)+gaph,W);
    
    H1 = numel(rgH1);
    W1 = numel(rgW1);
    ih1a = ih1 - min(rgH1) + 1;
    iw1a = iw1 - min(rgW1) + 1;
    ihw1a = unique(sub2ind([H1,W1],ih1a,iw1a));
    validMap1 = zeros(H1,W1);
    validMap1(ihw1a) = 1;
    
    tw1Vec = zeros(numel(ihw1a),T1);
    
    % for each pixel, replace time points from other events by baseline
    tBegin = T1;
    tEnd = 1;
    for ii=1:size(dat1SmoVec,1)
        lblOnePix = lbl1Vec(ii,:);
        dat1SmoOnePix = dat1SmoVec(ii,:);
        dat1OnePix = dat1Vec(ii,:);
        msk1OnePix = msk1Vec(ii,:);
        
        % time for previous or next events
        t0 = find(lblOnePix==dlyOrder(nn),1);
        t1 = find(lblOnePix==dlyOrder(nn),1,'last');
        t0p = find(lblOnePix(1:max(t0-1,1))>0,1,'last');
        if isempty(t0p)
            t0p = 1;
        end
        dt1p = find(lblOnePix(min(t1+1,T1):end)>0,1);
        if ~isempty(dt1p)
            t1p = min(dt1p + t1,T1);
        else
            t1p = T1;
        end
        
        % bounded by active region
        t0q = find(msk1OnePix(1:max(t0-1,1))==0,1,'last');
        if isempty(t0q)
            t0q = 1;
        end
        dt1q = find(lblOnePix(min(t1+1,T1):end)==0,1);
        if ~isempty(dt1q)
            t1q = min(dt1q + t1,T1);
        else
            t1q = T1;
        end
        t0p = max(t0p,t0q-gapt);
        t1p = min(t1p,t1q+gapt);
        
        % lowest point between events
        [x0,dt0a] = min(dat1SmoOnePix(t0p:t0));
        [x1,dt1a] = min(dat1SmoOnePix(t1:t1p));
        t0a = dt0a + t0p - 1;
        t1a = dt1a + t1 - 1;
        
        % signal low enough
        t0b = t0a;
        t1b = t1a;
        for tt=t0:-1:t0a
            if dat1SmoOnePix(tt)<x0+sqrt(opts.varEst)
                t0b = tt;
                break
            end
        end
        for tt=t1:t1a
            if dat1SmoOnePix(tt)<x1+sqrt(opts.varEst)
                t1b = tt;
                break
            end
        end
        
        dat1OnePix(1:t0b) = x0;
        dat1OnePix(t1b:end) = x1;
        
        dat1Vec(ii,:) = dat1OnePix;
        tBegin = min(tBegin,t0);
        tEnd = max(tEnd,t1);
        if opts.mergeMore>0
            tw1Vec(ii,t0b:t1b) = 1;  % do not consider falling
        else
            tw1Vec(ii,t0:t1) = 1;  % do not consider falling
        end
    end
    
    % data for fitting
    rgT = tBegin:tEnd;
    if numel(rgT)<3  % in case signal too short
        rgT = max(tBegin-2,1):min(tEnd+2,T1);
    end
    dat1a = zeros(H1*W1,T1);
    dat1a(validMap1>0,:) = dat1Vec;
    
    dat1b = dat1a(:,rgT);
    dat1b = dat1b - nanmin(dat1b,[],2);
    dat1b = reshape(dat1b,H1,W1,numel(rgT));    
    
    datc{nn} = dat1b;
    vmapc{nn} = validMap1;
    %vmapc{nn} = imdilate(validMap1,strel('square',3));
    vmapc1{nn} = validMap1;
    tw1Vecc{nn} = tw1Vec;
    rgTc{nn} = rgT;
    rgTxc{nn} = rgTx;
    rgHc{nn} = rgH1;
    rgWc{nn} = rgW1;
end
end

function dlyOrder = delayOrder(voxLst,H,W,T)
% early events first. The tail is less reliable. Later events can eat the tail.
tVec = Inf(numel(voxLst),1);
for nn=1:numel(voxLst)
    vox = voxLst{nn};
    if ~isempty(vox)
        [~,~,it0] = ind2sub([H,W,T],vox);
        tVec(nn) = min(it0);
    end
end
[~,dlyOrder] = sort(tVec,'ascend');
end

