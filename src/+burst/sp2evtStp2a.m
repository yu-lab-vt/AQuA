function lblMapC2 = sp2evtStp2a(lblMapC,lblMapS,riseMap,maxRiseDly,maxRiseUnc,smoLm)
% sp2evtStp2 split multi-source events to single source events

heLst = label2idx(lblMapC);
spLst = label2idx(lblMapS);

nSp = numel(spLst);
riseX = nan(nSp,1);
for nn=1:nSp
    vox0 = spLst{nn};
    if ~isempty(vox0)
        t0 = riseMap(vox0);
        t0 = t0(t0>0);
        riseX(nn) = nanmean(t0);
    end
end

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
    
    % member super pixels in this hyper event
    tmp = lblMapS(vox0);
    spIdx = unique(tmp(tmp>0));
    nSp = numel(spIdx);
    if nSp>1000
        fprintf('Big region - %d sps\n',nSp)
    end
    
    % crop
    [ih,iw,it] = ind2sub([H,W,T],vox0);
    rgH = min(ih):max(ih);
    rgW = min(iw):max(iw);
    rgT = min(it):max(it);
    rise0 = riseX(spIdx);
    riseMap0 = riseMap(rgH,rgW,rgT);
    
    % re-code super pixels
    sp = zeros(numel(rgH),numel(rgW),numel(rgT));
    spDlyMap = Inf(numel(rgH),numel(rgW));
    for ii=1:nSp
        voxSp0 = spLst{spIdx(ii)};
        [ih0,iw0,it0] = ind2sub([H,W,T],voxSp0);
        ih0a = ih0 - min(rgH) + 1;
        iw0a = iw0 - min(rgW) + 1;
        it0a = it0 - min(rgT) + 1;
        voxSp0a = sub2ind(size(sp),ih0a,iw0a,it0a);
        pixSp0a = sub2ind([numel(rgH),numel(rgW)],ih0a,iw0a);
        sp(voxSp0a) = ii;
        spDlyMap(pixSp0a) = min(spDlyMap(pixSp0a),rise0(ii));
    end
    
    % distance between super pixels
    distMat = burst.distSp(sp,riseMap0,maxRiseDly);
    
    % find local early super pixels (seeds)
    %     spDlyMap1 = spDlyMap;
    %     spDlyMap1(isinf(spDlyMap1)) = nan;
    %     spDlyMap1 = fillmissing(spDlyMap1,'nearest');
    
    if nSp>1000
        fprintf('Smoothing\n')
    end
    
    % optionally, smooth the delay map
    spDlyMap1 = spDlyMap;
    mskDly = ~isinf(spDlyMap);
    if smoLm>0
        mskOut = 1-mskDly;
        [ihx,iwx] = find(mskOut>0);
        [ihy,iwy] = find(mskDly>0);
        spDlyMapx = spDlyMap;
        for ii=1:numel(ihx)
            d00 = (ihx(ii)-ihy).^2+(iwx(ii)-iwy).^2;
            [~,ix] = min(d00);
            spDlyMapx(ihx(ii),iwx(ii)) = spDlyMap(ihy(ix),iwy(ix));
        end
        spDlyMap1 = medfilt2(spDlyMapx,'symmetric');
        spDlyMap1 = imgaussfilt(spDlyMap1,smoLm);
    end
    
    %tMapxx = spDlyMap1; tMapxx(mskOut>0) = nan; tMapxx(tMapxx>55) = 55;
    %figure;imagesc(tMapxx,'AlphaData',~isnan(tMapxx));colorbar;pause(0.2)
    
    lm = imregionalmin(spDlyMap1);
    lm = lm.*mskDly;
    %lm = bwareaopen(lm,2);
    if max(lm(:))==0
        lm = imregionalmin(spDlyMap);
    end
    cc = bwconncomp(lm);
    spVec = reshape(sp,[],numel(rgT));
    spSeedVec = [];
    spLoc = zeros(numel(rgH),numel(rgW));
    for ii=1:cc.NumObjects
        pix0 = cc.PixelIdxList{ii};
        sp00 = spVec(pix0,:);
        sp00 = sp00(sp00>0);
        spSeedVec = union(spSeedVec,sp00(1));
        spLoc(pix0) = sp00(1);
    end
    
    % remove weak local maximum
    if nSp>1000
        fprintf('Filtering\n')
    end
    
    if 0  % !! BAD Code
        rise00 = rise0(spSeedVec);
        [~,seedOrd] = sort(rise00);
        seedLbl = spSeedVec*0;
        nSeed = 0;
        for ii=1:numel(spSeedVec)
            if mod(ii,100)==0; fprintf('%d\n',ii); end
            idxCenter = spSeedVec(seedOrd(ii));
            idxMemCand = find(rise0<=rise0(idxCenter)+maxRiseUnc);
            distMat0 = distMat(idxMemCand,idxMemCand);
            distMat0(~isnan(distMat0)) = 1;
            distMat0(isnan(distMat0)) = 0;
            distMat0(eye(size(distMat0,1))>0) = 1;
            G = digraph(distMat0);
            s0 = find(idxMemCand==idxCenter);
            d0 = distances(G,s0);
            
            % distance to existing seed
            % start searching from earliest one
            idxMem = idxMemCand(d0<Inf);
            d0Mem = d0(d0<Inf);
            dist2Cur = inf(numel(spSeedVec),1);
            for jj=1:numel(spSeedVec)
                if seedLbl(jj)>0
                    ix1 = find(idxMem==spSeedVec(jj));
                    if ~isempty(ix1)
                        dist2Cur(jj) = d0Mem(ix1);
                    end
                end
            end
            
            % if connected to a seed, belong to it
            if sum(~isinf(dist2Cur))==0
                nSeed = nSeed + 1;
                seedLbl(seedOrd(ii)) = nSeed;
            end
        end
    end
    
    if 1
        rise00 = rise0(spSeedVec);
        [~,seedOrd] = sort(rise00);
        seedIdx = rise0*0;
        seedIdx(spSeedVec) = nan;
        seedLbl = rise0*0;
        % seedLbl = nan(size(spSeedVec));
        nSeed = 1;
        
        % check whether a seed is valid
        % start searching from earliest one
        for ii=1:numel(spSeedVec)
            if mod(ii,100)==0; fprintf('%d\n',ii); end
            idxCenter = spSeedVec(seedOrd(ii));
            if seedIdx(idxCenter)==0
                continue
            end
            riseCenter = rise0(idxCenter);
            
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
            %fprintf('m: %d\n',numel(idxMem))
            seedIdx(idxMem) = 0;
            seedIdx(idxCenter) = nSeed;
            seedLbl(idxMem) = nSeed;
            nSeed = nSeed + 1;
        end
        seedLblSel = seedLbl(spSeedVec);
        seedIdxSel = seedIdx(spSeedVec);
    end
    
    if 1
        spEvt = zeros(nSp,1);
        for ii=1:numel(spSeedVec)
            spEvt(spSeedVec(ii)) = seedIdxSel(ii);
        end
    else
        spEvt = seedLbl;
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



