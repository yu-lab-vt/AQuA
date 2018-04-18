function lmMapAll = getLmFromRisingMultiThr(tMapMT,cRise,cInt,dFx,Sx,s00)
% getLmFromRisingMultiThr use delay map to estimate local early rising regions
% From multiple delta F thresholds

[H0,W0,nThr] = size(tMapMT);

% all local minimum
lmMapx = zeros(H0,W0);
n00 = 0;
for iThr=nThr:-1:3
    tMap0 = tMapMT(:,:,iThr);
    tMap0(isnan(tMap0)) = Inf;
    lm = imregionalmin(tMap0);
    cc = bwconncomp(lm);
    for jj=1:cc.NumObjects
        pix00 = cc.PixelIdxList{jj};
        if sum(lmMapx(pix00))==0
            n00 = n00+1;
            lmMapx(pix00) = n00;
        end
    end
end
lmAll = label2idx(lmMapx);
lmThr = zeros(1,numel(lmAll));
for iThr=nThr:-1:3
    msk0 = tMapMT(:,:,iThr)>-1;
    for jj=1:numel(lmAll)
        if lmThr(jj)==0
            if sum(msk0(lmAll{jj}))>0
                lmThr(jj) = iThr;
            end
        end
    end
end

ov1a = plt.regionMapWithData(lmMapx,lmMapx*0,0.5); zzshow(ov1a);

% find good local minimums
lmMapAll = zeros(H0,W0);
lmLstPre = [];
lmLvlPre = [];

for iThr=nThr:-1:3
% for iThr=nThr
    fprintf('Thr: %d\n',iThr)
    
    % add local minimums and combine previous ones
    %lmLstCur = lmAll;
    %lmLvl = lmThr;
    lmLstCur = lmAll(lmThr==iThr);
    lmLvlCur = ones(1,numel(lmLstCur))*iThr;
    lmLst = [lmLstCur,lmLstPre];
    lmLvl = [lmLvlCur,lmLvlPre];
    lmSz = cellfun(@numel,lmLst);
    lmMap = zeros(H0,W0);
    for jj=1:numel(lmLst)
        pix0 = lmLst{jj};
        lmMap(pix0) = jj;
    end
    
    % direction between local minimums satisfying delay constraint
    % begin with current threhsold, and search lower thresholds
    % if one direction, allow high intensity to low; if mutual, allow any
    % intensity distance: clean direction use intensity
    for jThr=iThr:-1:1
        fprintf('-- %d\n',jThr)
        tMap1 = tMapMT(:,:,jThr);
        
        lmMap = zeros(H0,W0);
        for jj=1:numel(lmLst)
            lmMap(lmLst{jj}) = jj;
        end
        
        nLm = numel(lmLst);
        ccMat = zeros(nLm,nLm);  % direction distance satisfactory matrix
        ddMat = zeros(nLm,nLm);  % intensity distance matrix
        
        % rising time in current level
        % need integer value that exist in tMap1
        lmOt = nan(1,nLm);
        for jj=1:numel(lmLst)
            pix0 = lmLst{jj};
            lmOt(jj) = round(median(tMap1(pix0)));
        end
        
        % rank seeds according to intensity level, occurring time and size
        P = [lmLvl',-lmOt',lmSz',(1:nLm)'];
        Ps = sortrows(P,[1 2 3],'descend');
        lmRnk = lmLvl*0;
        lmRnk(Ps(:,4)) = 1:numel(lmLvl);
        
        % scan relevant time points
        tVec = tMap1(:);
        tVec = tVec(~isnan(tVec) & ~isinf(tVec) & (tVec~=0));
        tVec = sort(union(unique(tVec),lmOt));
        lmLvl0 = lmLvl-jThr;
        for jj=1:numel(tVec)
            tMap0t = tMap1<tVec(jj)+cRise;
            cct = bwconncomp(tMap0t);
            
            % local minimums in current connected component are connected
            for kk=1:cct.NumObjects
                pix00 = cct.PixelIdxList{kk};
                idx00 = unique(lmMap(pix00));
                idx00 = idx00(idx00>0);
                if ~isempty(idx00)
                    
                    % find sources for local minimums happening in this time
                    idx00Cur = idx00(lmOt(idx00)==tVec(jj));
                    if ~isempty(idx00Cur)
                        idx00Bef = idx00(lmOt(idx00)<=tVec(jj));
                        ccMat(idx00Bef,idx00Cur) = 1;
                    end
                end
            end
        end
        
        % new connections due to lower threshold
        [ih,iw] = find(ccMat>0);
        ddMat(ccMat>0) = min(lmLvl0(ih),lmLvl0(iw));
        ccMat(ddMat>cInt) = 0;        
        ccMat(eye(nLm)>0) = 1;  % some local minimus not visited
        if sum(ccMat(:))==0
            break
        end
        
        % group local minimums
        % keep anything from higher layer
        [s,t] = find(ccMat>0);
        G = digraph(s,t);
        d = distances(G);
        [~,ixVec] = sort(lmRnk,'ascend');
        lmGrp = cell(1);
        lmCen = cell(1);
        lmUsed = zeros(nLm,1);
        ee = 1;
        for jj=1:numel(ixVec)
            ix0 = ixVec(jj);
            if lmUsed(ix0)>0
                continue
            end
            ix0Neib = d(ix0,:);
            ix0Neib(lmUsed>0) = Inf;
            ix0Neib(lmLvl>iThr) = Inf;
            ix0Neib = find(~isinf(ix0Neib));
            lmCen{ee} = ix0;
            lmGrp{ee} = ix0Neib;
            lmUsed(ix0Neib) = 1;
            ee = ee + 1;
        end
        lmCen = cell2mat(lmCen);
        
        lmLst = lmLst(lmCen);
        lmLvl = lmLvl(lmCen);
        lmSz = lmSz(lmCen);
    end
    
    % prepare for next threshold, choose good local minimums
    for jj=1:numel(lmLst)
        pix00 = lmLst{jj};
        if sum(lmMapAll(pix00)~=0)==0
            lmMapAll(lmLst{jj}) = iThr;
        end
    end
    lmLstPre = lmLst;
    lmLvlPre = lmLvl;
    
    % visualize one threshold
    if 1
        lmMapPreRep = repmat(lmMapAll,1,1,size(dFx,3));
        lmMapPreRep(lmMapPreRep<0) = 0;
        ov4a = plt.regionMapWithData(lmMapPreRep,dFx,0.5); 
        zzshow(ov4a,num2str(iThr));
    end
end

% visualize all
if 0
    dFxHi = dFx>6*s00; dFxHi(Sx==0) = 0; dFxHi = bwareaopen(dFxHi,4,8);
    ov4b = zeros(H0,W0,3,size(dFx,3)); ov4b(:,:,1,:) = dFxHi*0.5;
    ov4b(:,:,2,:) = dFx; zzshow(ov4b);
    
    for jThr=nThr:-1:1
        tMap0a = tMapMT(:,:,jThr);        
        tMap0ax = tMap0a; tMap0ax(tMap0a>40) = 40;
        figure;imagesc(tMap0ax,'AlphaData',~isnan(tMap0ax));colorbar;
    end
end

end


