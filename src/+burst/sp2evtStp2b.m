function lblMapC2 = sp2evtStp2b(dF,lblMapC,lblMapS,riseMap,maxRiseDly,maxRiseUnc,smoLm,varEst)
% sp2evtStp2 split multi-source events to single source events

heLst = label2idx(lblMapC);

[H,W,T] = size(lblMapC);
lblMapC2 = zeros([H,W,T],'uint32');

nEvt = 0;
for nn=1:numel(heLst)
    if mod(nn,100)==0; fprintf('%d ----- \n',nn); end
    %if nn==267; keyboard; else; continue; end
    vox0 = heLst{nn};    
    if isempty(vox0)
        continue
    end    
    if numel(vox0)>1e6
        fprintf('Big region\n')
    else
        %continue
    end
    
    % member super pixels in this hyper event
    [ih,iw,it] = ind2sub([H,W,T],vox0);
    rgH = min(ih):max(ih);
    rgW = min(iw):max(iw);
    rgT = min(it):max(it);
    riseMap0 = riseMap(rgH,rgW,rgT);
    
    % rising maps for different levels
    dFx = dF(rgH,rgW,rgT);  % delta F
    [H0,W0,T0] = size(dFx);
    
    Lx = lblMapC(rgH,rgW,rgT);  % super event map
    Sx = lblMapS(rgH,rgW,rgT);  % super voxel map
    dFx(Lx>0 & Lx~=nn) = 0;
    Sx(Lx>0 & Lx~=nn) = 0;
    Mx = sum(Sx,3)>0;
    
    % re-code sp
    SxMin = nanmin(Sx(:));
    Sx(Sx>0) = Sx(Sx>0)-SxMin+1;
    spLst = label2idx(Sx);
    n00 = 1;
    sp = zeros(H0,W0,T0);
    for ii=1:numel(spLst)
        vox0 = spLst{ii};
        if ~isempty(vox0)
            sp(vox0) = n00;
            n00 = n00 + 1;
        end
    end
    spLst = label2idx(sp);
    nSp = numel(spLst);
    
    %xx0 = dFx(Sx>0)/sqrt(varEst);
    %qt0 = quantile(xx0,0.99);
    %thrVec = floor(qt0/2);
    thrVec = 0:5;
    szVec = [16,16,16,16,16,16,16];
    tMapMT = zeros(H0,W0,numel(thrVec));
    %for ii=thrSel
    for ii=1:numel(thrVec)
        fprintf('Delay map %d\n',thrVec(ii))
        dFxHi = dFx>thrVec(ii)*sqrt(varEst);
        dFxHi(sp==0) = 0;
        dFxHi = bwareaopen(dFxHi,szVec(ii),8);
        M0 = sum(dFxHi,3)>0 & Mx;
        tMap = nan(H0,W0);
        for hh=1:H0
            for ww=1:W0
                if M0(hh,ww)
                    x0 = squeeze(dFxHi(hh,ww,:));
                    t0 = find(x0,1);
                    if ~isempty(t0)
                        tMap(hh,ww) = t0;
                    end
                end
            end
        end
        tMapMF = tMap;
        mskDly = ~isnan(tMapMF);
        mskOut = 1-mskDly;
        [ihx,iwx] = find(mskOut>0);
        [ihy,iwy] = find(mskDly>0);
        if isempty(ihy) || isempty(ihx)
            continue
        end
        spDlyMapx = tMapMF;
        for jj=1:numel(ihx)
            d00 = (ihx(jj)-ihy).^2+(iwx(jj)-iwy).^2;
            [~,ix] = min(d00);
            spDlyMapx(ihx(jj),iwx(jj)) = spDlyMapx(ihy(ix),iwy(ix));  % !!
        end
        tMapMF = medfilt2(spDlyMapx,[5,5],'symmetric');
        %tMapMF = imgaussfilt(tMapMF,1);
        tMapMF(mskOut>0) = nan;
        %tMapMF(mskOut>0) = max(tMapMF);  % !!
        
        %zzshow(mskOut);
        %tMapxx = tMapMF; tMapxx(tMapxx>35) = 35;
        %figure;imagesc(tMapxx,'AlphaData',~isnan(tMapxx));colorbar;pause(0.2)
        
        tMapMT(:,:,ii) = tMapMF;
    end
    
    spDlyMap1 = tMapMT(:,:,end);
    for ii=numel(thrVec)-1:-1:1
        spDlyMap1x = tMapMT(:,:,ii);
        spDlyMap1(isnan(spDlyMap1)) = spDlyMap1x(isnan(spDlyMap1));
    end
    spDlyMap1(isnan(spDlyMap1)) = Inf;
    
    %tMapxx = spDlyMap1; tMapxx(tMapxx>35) = 35;
    %figure;imagesc(tMapxx,'AlphaData',~isnan(tMapxx));colorbar;pause(0.2)
    
    rise0 = zeros(nSp,1);
    for ii=1:nSp
        vox0 = spLst{ii};
        [h0,w0,~] = ind2sub([H0,W0,T0],vox0);
        hw0 = unique(sub2ind([H0,W0],h0,w0));
        rise0(ii) = nanmedian(spDlyMap1(hw0));
    end
    
    % distance between super pixels
    distMat = burst.distSp(sp,riseMap0,maxRiseDly);
    
    % local minimum
    lm = imregionalmin(spDlyMap1);
    lm = lm.*mskDly;
    cc = bwconncomp(lm);
    spVec = reshape(sp,[],numel(rgT));
    spSeedVec = [];
    for ii=1:cc.NumObjects
        pix0 = cc.PixelIdxList{ii};
        sp00 = spVec(pix0,:);
        sp00 = sp00(sp00>0);
        spSeedVec = union(spSeedVec,sp00(1));
    end
    
    % remove weak local maximum
    if nSp>1000
        fprintf('Filtering\n')
    end
    
    rise00 = rise0(spSeedVec);
    [~,seedOrd] = sort(rise00);
    seedIdx = rise0*0;
    seedIdx(spSeedVec) = nan;
    
    % check whether a seed is valid
    % start searching from earliest one
    nSeed = 1;
    for ii=1:numel(spSeedVec)
        if mod(ii,100)==0; fprintf('%d\n',ii); end
        idxCenter = spSeedVec(seedOrd(ii));
        if seedIdx(idxCenter)==0  % already determined
            continue
        end
        riseCenter = rise0(idxCenter);  % new seed
        
        % seeds earlier than idxCenter already try to connect idxCenter, but failed
        idxMemCand = find(rise0<=riseCenter+maxRiseUnc & rise0>=riseCenter);
        distMat0 = distMat(idxMemCand,idxMemCand);
        distMat0(~isnan(distMat0)) = 1;
        distMat0(isnan(distMat0)) = 0;
        distMat0(eye(size(distMat0,1))>0) = 1;
        G = digraph(distMat0);
        s0 = find(idxMemCand==idxCenter);
        d0 = distances(G,s0);
        
        % distance to existing seed
        idxMem = idxMemCand(d0<Inf);
        seedIdx(idxMem) = 0;
        seedIdx(idxCenter) = nSeed;
        nSeed = nSeed + 1;
    end        
    spEvt = zeros(nSp,1);
    spEvt(spSeedVec) = seedIdx(spSeedVec);
    
    if 0
        lm0 = zeros(H0,W0);
        lm1 = zeros(H0,W0);
        for ii=1:numel(spSeedVec)
            sp00 = spSeedVec(ii);
            [h0,w0,~] = ind2sub([H0,W0,T0],spLst{sp00});
            hw0 = unique(sub2ind([H0,W0],h0,w0));
            lm0(hw0) = 1;
            if seedIdx(sp00)>0
                lm1(hw0) = 1;
            end
        end
        zzshow(lm0)
        zzshow(lm1)
    end
    
    % grow see
    if nSp>1000
        fprintf('Growing\n')
    end
    spEvt = burst.sp2evtStp2_growSeed(spEvt,distMat,rise0,sp);
    
    % gather events
    voxLst = label2idx(sp);
    evt = zeros(size(sp));
    evt0 = unique(spEvt);
    evt0 = evt0(evt0>0);
    nEvt0 = numel(evt0);
    for ii=1:nEvt0
        vox0 = voxLst(spEvt==evt0(ii));
        for jj=1:numel(vox0)
            vox00 = vox0{jj};
            evt(vox00) = ii;
        end
    end
    
    evt(evt>0) = evt(evt>0) + nEvt;
    lblMapC2(rgH,rgW,rgT) = lblMapC2(rgH,rgW,rgT) + uint32(evt);
    nEvt = nEvt + nEvt0;
end
end



