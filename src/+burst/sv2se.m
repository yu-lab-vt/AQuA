function lblMapC1 = sv2se(lblMapS,neibLst,exldLst)
% sv2se combine super voxels to super events

[H,W,T] = size(lblMapS);
spVoxLst = label2idx(lblMapS);
nSp = numel(spVoxLst);

% find one super event in each connected component
ccL = bwconncomp(lblMapS>0);
ccLst = ccL.PixelIdxList;

if (isempty(ccLst)|| numel(ccLst)==0)
   lblMapC1 = zeros(H,W,T,'uint32');
   return;
end

evtLbl = nan(nSp,1);  % super event label for each super voxel
nSe = 0;
while 1
    % find largest connected component
    ccSz = cellfun(@numel,ccLst);
    [x00,nnMax] = max(ccSz);
    if x00==0
        break
    end
    
    % extract current component
    % !! connected component not the same as super voxel connectivity
    msk0 = ccLst{nnMax};
    idxSv0 = unique(lblMapS(msk0(:)));
    idxSv0 = idxSv0(isnan(evtLbl(idxSv0)));
    if isempty(idxSv0)
        ccLst{nnMax} = [];
        continue
    end
    msk0 = cell2mat(spVoxLst(idxSv0)');    
    ccLst{nnMax} = msk0;
    
    nSe = nSe+1;
    if mod(nSe,100)==0
        fprintf('SE: %d\n',nSe)
    end
    
    [ih,iw,it] = ind2sub([H,W,T],msk0);
    rgh = min(ih):max(ih);
    rgw = min(iw):max(iw);
    rgt = min(it):max(it);
    H1 = numel(rgh);
    W1 = numel(rgw);
    T1 = numel(rgt);
    msk0 = sub2ind([H1,W1,T1],ih-min(rgh)+1,iw-min(rgw)+1,it-min(rgt)+1);
    mapS0 = zeros(H1,W1,T1);
    lblMapS0 = lblMapS(rgh,rgw,rgt);
    mapS0(msk0) = lblMapS0(msk0);
    
    % find largest 2D region in this component as a new super event
    regLst = cell(1);
    regSz = zeros(1);
    nReg = 0;
    for tt=1:T1
        map0 = mapS0(:,:,tt);
        if sum(map0(:))>0
            cc = bwconncomp(map0);
            for ii=1:cc.NumObjects
                nReg = nReg + 1;
                sp00 = unique(map0(cc.PixelIdxList{ii}));
                idxSel = ~isnan(evtLbl(sp00));
                if sum(idxSel)>0
                    % keyboard
                end
                regLst{nReg} = sp00;      
                regSz(nReg) = numel(cc.PixelIdxList{ii});
            end
        end
    end
    [~,ix] = max(regSz);
    se0 = regLst{ix};  % suepr voxels in region with largest area
    se0 = se0(isnan(evtLbl(se0)));  % super voxels not used yet
    
    % gather other super voxels
    evtLbl(se0) = nSe;
    svVec = se0;  % super voxels in this super event
    newSp = se0;
    while 1
        newSp1 = [];
        for jj=1:numel(newSp)
            neib0 = neibLst{newSp(jj)};
            for uu=1:numel(neib0)
                if isnan(evtLbl(neib0(uu)))
                    exld0 = exldLst{neib0(uu)};
                    if sum(evtLbl(exld0)==nSe)==0
                        newSp1 = union(newSp1,neib0(uu));
                    end
                end
            end
        end
        if isempty(newSp1)
            break
        end
        evtLbl(newSp1) = nSe;
        newSp = newSp1;
        svVec = union(svVec,newSp1);
    end
    
    % remove super voxels already used
    for ii=1:numel(svVec)
        [ih0,iw0,it0] = ind2sub([H,W,T],spVoxLst{svVec(ii)});
        ih0 = ih0-min(rgh)+1;
        iw0 = iw0-min(rgw)+1;
        it0 = it0-min(rgt)+1;
        ih0 = min(max(ih0,1),H1);  % in case it goes outside this component
        iw0 = min(max(iw0,1),W1);
        it0 = min(max(it0,1),T1);
        vox00 = sub2ind([H1,W1,T1],ih0,iw0,it0);
        mapS0(vox00) = 0;
    end
    
    % update connect component map
    ccLst{nnMax} = [];
    ccL1 = bwconncomp(mapS0);    
    if ccL1.NumObjects>0
        ccLst1 = ccL1.PixelIdxList;
        for ii=1:numel(ccLst1)
            [ih0,iw0,it0] = ind2sub([H1,W1,T1],ccLst1{ii});
            ih0 = ih0+min(rgh)-1;
            iw0 = iw0+min(rgw)-1;
            it0 = it0+min(rgt)-1;
            ccLst1{ii} = sub2ind([H,W,T],ih0,iw0,it0);
        end
        ccLst(nnMax) = ccLst1(1);
        if ccL1.NumObjects>1
            ccLst(end+1:end+numel(ccLst1)-1) = ccLst1(2:end);
        end
    end
end


% update super pixel map
xx = unique(evtLbl);
xx = xx(~isnan(xx));
lblMapC1 = zeros(H,W,T,'uint32');
for ii=1:numel(xx)
    idx = find(evtLbl==xx(ii));
    for jj=1:numel(idx)
        vox0 = spVoxLst{idx(jj)};
        lblMapC1(vox0) = uint32(ii);
    end
end

%ov1 = plt.regionMapWithData(lblMapS1,dat.^2*0.3,0.5); zzshow(ov1);
%pause(0.5);
%keyboard

end











