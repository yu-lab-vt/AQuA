function lblMapX = extendVoxGrp(lblMap,dfSmo,dL,varEst)
% extendEvent extend voxels groups
% use datSmo to determine temporal boundary between events
% use datMsk to avoid voxels with weak signals

voxLst = label2idx(lblMap);
nRg = numel(voxLst);
[H,W,T] = size(dfSmo);
dlyOrder = 1:numel(voxLst);
gapt = 10;  % 3

datSmoVec = reshape(dfSmo,[],T); clear dfSmo;
lblMapFVec = reshape(lblMap,[],T); clear lblMap;
datMskVec = reshape(dL,[],T); clear dL;

lblMapX = zeros(size(datSmoVec),'uint32');
nSp = 1;
for nn=1:nRg
    if mod(nn,1000)==0
        fprintf('%d\n',nn)
    end
    
    % current super voxel and spatial footprint
    vox = voxLst{dlyOrder(nn)};
    if isempty(vox)
        continue
    end
    [ih1,iw1,it1] = ind2sub([H,W,T],vox);
    ihw1 = unique(sub2ind([H,W],ih1,iw1));    
    if numel(ihw1)<4
        continue
    end
    
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
    dat1SmoVec = datSmoVec(ihw1,rgTx);
    lbl1Vec = lblMapFVec(ihw1,rgTx);
    
    % for each pixel, replace time points from other events by baseline
    for ii=1:size(dat1SmoVec,1)
        lblOnePix = lbl1Vec(ii,:);
        dat1SmoOnePix = dat1SmoVec(ii,:);
        msk1OnePix = msk1Vec(ii,:);
        
        % bounded by previous and/or next events
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
        
        % lowest point between temporal adjacent events
        [x0,dt0a] = min(dat1SmoOnePix(t0p:t0));
        [x1,dt1a] = min(dat1SmoOnePix(t1:t1p));
        t0a = dt0a + t0p - 1;
        t1a = dt1a + t1 - 1;
        
        % stop if signal low enough
        t0b = t0a;
        t1b = t1a;
        for tt=t0:-1:t0a
            if dat1SmoOnePix(tt)<x0+sqrt(varEst)
                t0b = tt;
                break
            end
        end
        for tt=t1:t1a
            if dat1SmoOnePix(tt)<x1+sqrt(varEst)
                t1b = tt;
                break
            end
        end
        
        % save current pixel
        t00a = min(rgTx)+t0b-1;
        t00b = min(rgTx)+t1b-1;
        lblMapX(ihw1(ii),t00a:t00b) = nSp;
    end
    nSp = nSp + 1;
end

lblMapX = reshape(lblMapX,[H,W,T]);

end

