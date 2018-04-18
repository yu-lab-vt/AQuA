function lblMapC2 = sp2evtStp2(lblMapC,lblMapS,riseMap,riseX,maxRiseDly,maxRiseUnc)
% sp2evtStp2 split multi-source events to single source events

[H,W,T] = size(lblMapC);
lblMapC2 = zeros([H,W,T]);
heLst = label2idx(lblMapC);
spLst = label2idx(lblMapS);
nEvt = 0;
for nn=1:numel(heLst)
    if mod(nn,100)==0; fprintf('%d\n',nn); end
    if nn==168; keyboard; end
    vox0 = heLst{nn};
    
    % member super pixels in this hyper event
    tmp = lblMapS(vox0);
    spIdx = unique(tmp(tmp>0));
    nSp = numel(spIdx);
    
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
    %distMat(distMat>2) = distMat(distMat>2) + (distMat(distMat>2)-2).^3;
    
    % find local early super pixels (seeds)
    %spSeed = zeros(nSp,1);
    spEvt = zeros(nSp,1);
    
    % local minimum
    %mskDly = ~isinf(spDlyMap);
    spDlyMap = imgaussfilt(spDlyMap,2);
    lm = imregionalmin(spDlyMap);
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
        %spEvt(sp00(1)) = sp00(1);
    end
    
    rise00 = rise0(spSeedVec);
    [~,seedOrd] = sort(rise00);
    seedLbl = spSeedVec*0;
    for ii=1:numel(spSeedVec)
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
            seedLbl(seedOrd(ii)) = seedOrd(ii);
        else
            %[~,ix1] = min(dist2Cur);
            %seedLbl(seedOrd(ii)) = seedLbl(ix1);
        end
    end
    
    for ii=1:numel(spSeedVec)
        spEvt(spSeedVec(ii)) = seedLbl(ii);
    end
    
    %     % combine local minimums
    %     seedConn = zeros(numel(spSeedLst));
    %     for ii=1:numel(spSeedLst)
    %         idxCenter = spSeedLst(ii);
    %         idxMemCand = find(rise0<=rise0(idxCenter)+maxRiseUnc);
    %         distMat0 = distMat(idxMemCand,idxMemCand);
    %         distMat0(~isnan(distMat0)) = 1;
    %         distMat0(isnan(distMat0)) = 0;
    %         distMat0(eye(size(distMat0,1))>0) = 1;
    %         G = digraph(distMat0);
    %         s0 = find(idxMemCand==idxCenter);
    %         d0 = distances(G,s0);
    %         if ~isempty(d0)
    %             idxMem = idxMemCand(d0<Inf);
    %             for jj=1:numel(spSeedLst)
    %                 if sum(spSeedLst(jj)==idxMem)>0
    %                     seedConn(ii,jj) = 1;
    %                     %seedConn(jj,ii) = 1;
    %                 end
    %             end
    %         end
    %     end
    %
    %     seedConn(eye(size(seedConn))>0) = 1;
    %     rise00 = rise0(spSeedLst);
    %     [~,ix] = sort(rise00);
    %     for ii=1:numel(spSeedLst)
    %         if seedConn(ix(ii),ix(ii))==0
    %             continue
    %         end
    %         idx = spSeedLst(ix(ii));
    %         idxN = find(seedConn(ix(ii),:)>0);
    %         spEvt(idx) = idx;
    %         spEvt(idxN) = idx;
    %         seedConn(idxN,:) = 0;
    %         seedConn(:,idxN) = 0;
    %     end
    
    %     G = digraph(seedConn);
    %     cc = conncomp(G,'Type','weak','OutputForm','cell');
    %     for ii=1:numel(cc)
    %         cc0 = cc{ii};
    %         sp0 = spSeedLst(cc0);
    %         [~,ix] = min(rise0(sp0));
    %         sp0 = sp0(ix);
    %         spEvt(sp0) = sp0;
    %     end
    
    %     [~,dlyOrder] = sort(rise0,'ascend');
    %     for ii=1:nSp
    %         idxCenter = dlyOrder(ii);
    %         if spSeed(idxCenter)>0
    %             continue
    %         end
    %         spEvt(idxCenter) = idxCenter;
    %         idxMemCand = find(rise0<=rise0(idxCenter)+maxRiseUnc);
    %         distMat0 = distMat(idxMemCand,idxMemCand);
    %         distMat0(~isnan(distMat0)) = 1;
    %         distMat0(isnan(distMat0)) = 0;
    %         distMat0(eye(size(distMat0,1))>0) = 1;
    %         G = digraph(distMat0);
    %         s0 = find(idxMemCand==idxCenter);
    %         d0 = distances(G,s0);
    %         if ~isempty(d0)
    %             idxMem = idxMemCand(d0<Inf);
    %             spSeed(idxMem) = idxCenter;
    %         end
    %     end
    
    % assign pixels to seeds
    [s,t] = find(~isnan(distMat));
    w = distMat(sub2ind([nSp,nSp],s,t));
    [~,wOrd] = sort(w,'ascend');
    edgeUsed = w*0;
    for kk=1:numel(w)
        %fprintf('%d\n',kk)
        if sum(edgeUsed==0)==0
            break
        end
        for ii=1:numel(w)
            if edgeUsed(wOrd(ii))==1
                continue
            end
            s0 = s(wOrd(ii));
            t0 = t(wOrd(ii));
            if spEvt(s0)>0 && spEvt(t0)==0
                spEvt(t0) = spEvt(s0);
                edgeUsed(wOrd(ii))=1;
                break
            elseif spEvt(t0)>0 && spEvt(s0)==0
                spEvt(s0) = spEvt(t0);
                edgeUsed(wOrd(ii))=1;
                break
            elseif spEvt(t0)>0 && spEvt(s0)>0
                edgeUsed(wOrd(ii))=1;
                break
            end
        end
    end
    
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
    lblMapC2(rgH,rgW,rgT) = lblMapC2(rgH,rgW,rgT) + evt;
    nEvt = nEvt + nEvt0;
end
end



