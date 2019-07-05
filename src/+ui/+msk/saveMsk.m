function saveMsk(~,~,f,op)
    
    fh = guidata(f);
    opts = getappdata(f,'opts');
    sz = opts.sz;
    
    if op==1  % go back without saving
        fh.g.Selection = 3;
        return
    end
    
    bd = getappdata(f,'bd');
    if isKey(bd,'maskLst')
        bdMsk = bd('maskLst');
    else
        bdMsk = [];
    end
    
    if isempty(bdMsk)
        fh.g.Selection = 3;
        return
    end
    
    % combine masks
    opReg = fh.saveMskRegOp.Value;
    opLmk = fh.saveMskLmkOp.Value;
    opMar = fh.saveMarkerOp.Value;
    fgMsk = ones(sz(1),sz(2));
    bgMsk = zeros(sz(1),sz(2));
    regMskAll = [];
    lmkMskAll = [];
    markerMap = [];
    minRegSz = 1e8;
    minLmkSz = 1e8;
    for ii=1:numel(bdMsk)
        rr0 = bdMsk{ii};
        if strcmp(rr0.type,'region')
            minRegSz = min(minRegSz,rr0.minSz);
            if isempty(regMskAll)
                regMskAll = double(rr0.mask>0);
                continue
            end
            switch opReg
                case 1
                    regMskAll = regMskAll+double(rr0.mask>0);
                case 2
                    regMskAll = regMskAll.*double(rr0.mask>0);
                case 3
                    regMskAll(rr0.mask>0) = 0; %#ok<AGROW>
            end
        end
        if strcmp(rr0.type,'landmark')
            minLmkSz = min(minLmkSz,rr0.minSz);
            if isempty(lmkMskAll)
                lmkMskAll = double(rr0.mask);
                continue
            end
            switch opLmk
                case 1
                    lmkMskAll = lmkMskAll+double(rr0.mask>0);               
                case 2
                    lmkMskAll = lmkMskAll.*double(rr0.mask>0);
                case 3
                    lmkMskAll(rr0.mask>0) = 0; %#ok<AGROW>
            end
        end
        if strcmp(rr0.type,'regionMarker')
            markerMap = rr0.mask;
        end
        if strcmp(rr0.type,'foreground')
            fgMsk = rr0.mask;
        end
        if strcmp(rr0.type,'background')
            bgMsk = rr0.mask;
        end
    end
    
    % get regions and landmarks data structure
    regA = bwareaopen(regMskAll>0,round(minRegSz/4));
    lmkA = bwareaopen(lmkMskAll>0,round(minLmkSz/4));
    
    % segment regions using region markers and get boundaries --------------
    if ~isempty(markerMap)
        [H,W] = size(markerMap);
        markerIdxMap = bwlabel(markerMap);
        markerLst = label2idx(markerIdxMap);
        
        ccRegA = bwconncomp(regA);
        nReg = ccRegA.NumObjects;
        ccRegx = cell(0);
        nn = 1;
        
        for ii=1:nReg
            % markers overlapped with regions
            pix00 = ccRegA.PixelIdxList{ii};
            idx00 = markerIdxMap(pix00);
            idx00 = idx00(idx00>0);
            idx00 = unique(idx00);
            
            if opMar==1  % segmentation with distance transform
                if numel(idx00)>1
                    markerSel = markerLst(idx00);
                    bw = zeros(H,W);
                    bw(pix00) = 1;
                    distMat = nan(H,W,numel(idx00));
                    for jj=1:numel(idx00)
                        mk = zeros(H,W);
                        mk(markerSel{jj}) = 1;
                        tmp = bwdistgeodesic(bw>0,mk>0);
                        distMat(:,:,jj) = tmp;
                    end
                    [~,lbl00] = nanmin(distMat,[],3);
                    msk00 = zeros(H,W);
                    msk00(pix00) = 1;
                    lbl00(msk00==0) = nan;
                    for jj=1:numel(idx00)
                        tmp = lbl00==jj;
                        if sum(tmp(:))>0
                            %cc = bwboundaries(tmp);
                            %ccRegx{nn} = cc{1};
                            ccRegx{nn} = find(tmp>0);
                            nn = nn + 1;
                        end
                    end
                else
                    %tmp = zeros(H,W);
                    %tmp(pix00) = 1;
                    %cc = bwboundaries(tmp);
                    %ccRegx{nn} = cc{1};
                    ccRegx{nn} = pix00;
                    nn = nn + 1;
                end
            end
            
            if opMar==2  % delete regions containing any mask
                if numel(idx00)==0
                    %tmp = zeros(H,W);
                    %tmp(pix00) = 1;
                    %cc = bwboundaries(tmp);
                    %ccRegx{nn} = cc{1};
                    ccRegx{nn} = pix00;
                    nn = nn + 1;                    
                end
            end
        end
        ccReg = [];
        ccReg.NumObjects = numel(ccRegx);
        ccReg.PixelIdxList = ccRegx;
    else
        ccReg = bwconncomp(regA);
        %ccReg = bwboundaries(regA,'noholes');
    end
    
    ccLmk = bwconncomp(lmkA);
    %ccLmk = bwboundaries(lmkA,'noholes');

    % export ------------           
    % clear previous regions from masks
    if bd.isKey('cell')
        regAll = bd('cell');
    else
        regAll = [];
    end
    for ii=1:numel(regAll)
        tmp = regAll{ii};
        if numel(tmp)>2 && strcmp(tmp{3},'auto')
            regAll{ii} = [];
        end        
    end
    if numel(regAll)>0
        regAll = regAll(~cellfun(@isempty,regAll));
    end
    
    if bd.isKey('landmk')
        lmkAll = bd('landmk');
    else
        lmkAll = [];
    end
    for ii=1:numel(lmkAll)
        tmp = lmkAll{ii};
        if numel(tmp)>2 && strcmp(tmp{3},'auto')
            lmkAll{ii} = [];
        end        
    end
    if numel(lmkAll)>0
        lmkAll = lmkAll(~cellfun(@isempty,lmkAll));
    end
    
    % add new
    H = opts.sz(1);
    W = opts.sz(2);
    nNow = numel(regAll);
    for ii=1:ccReg.NumObjects
        tmp = [];
        xx = ccReg.PixelIdxList{ii};
        if numel(xx)>10
            msk = zeros(H,W);
            msk(xx) = 1;
            tmp{1} = bwboundaries(msk);
            %tmp{1} = [xx(:,2),H-xx(:,1)+1];
            tmp{2} = xx;
            tmp{3} = 'auto';
            tmp{4} = 'None';
            regAll{nNow+1} = tmp;
            nNow = nNow+1;
        end
    end
    
    % left->right top->bottom
    regAllS = cell(1,numel(regAll));
    pos = zeros(1,numel(regAll));
    for i = 1:numel(regAll)
        pix = regAll{i}{2};
        [ih0,iw0] = ind2sub(opts.sz(1:2),pix);
        ihw = sub2ind([opts.sz(2),opts.sz(1)],iw0,ih0);
        pos(i) = min(ihw);
    end
    [~,num] = sort(pos);
    for i = 1:numel(regAll)
        regAllS{i} = regAll{num(i)};
    end
    bd('cell') = regAllS;
    
    
    nNow = numel(lmkAll);
    for ii=1:ccLmk.NumObjects
        tmp = [];
        xx = ccLmk.PixelIdxList{ii};
        msk = zeros(H,W);
        msk(xx) = 1;
        tmp{1} = bwboundaries(msk);
        tmp{2} = xx;
        tmp{3} = 'auto';
        tmp{4} = 'None';
        lmkAll{nNow+ii} = tmp;
    end
    
    % left->right top->bottom
    lmkAllS = cell(1,numel(lmkAll));
    pos = zeros(1,numel(lmkAll));
    for i = 1:numel(lmkAll)
        pix = lmkAll{i}{2};
        [ih0,iw0] = ind2sub(opts.sz(1:2),pix);
        ihw = sub2ind([opts.sz(2),opts.sz(1)],iw0,ih0);
        pos(i) = min(ihw);
    end
    [~,num] = sort(pos);
    for i = 1:numel(lmkAll)
        lmkAllS{i} = lmkAll{num(i)};
    end
    
    bd('landmk') = lmkAllS;
    
    setappdata(f,'bd',bd);

    % foreground and background
    dat = getappdata(f,'datOrg');
    datAvg = mean(dat,3);
    if sum(bgMsk(:)==0)>0
        bgFluo = median(datAvg(bgMsk==0));
    else
        bgFluo = 0;
    end
    opts.bgFluo = double(bgFluo);
    opts.fgFluo = double(min(datAvg(fgMsk>0)));
    setappdata(f,'opts',opts);

    fh.g.Selection = 3;
    
    ui.movStep(f,[],[],1);
    
end

