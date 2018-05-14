function viewImgMsk(~, ~, f)

    fh = guidata(f);
    ax = fh.imgMsk;
    im = fh.imsMsk;

    hh = findobj(ax, 'Type', 'text');
    delete(hh);

    bd = getappdata(f, 'bd');
    bdMsk = bd('maskLst');

    % rr.name = ffName;
    % rr.datAvg = datAvg;
    % rr.type = mskType;
    % rr.thr = datLevel;
    % rr.minSz = 0;
    % rr.maxSz = 1e8;

    tbDat = cell2mat(fh.mskTable.Data(:, 1));
    ix = find(tbDat, 1);

    rr = bdMsk{ix};

    datAvg = rr.datAvg;
    [H, W] = size(datAvg);

    % remove too small and too large
    mskx = datAvg > rr.thr;
    mskx = bwareaopen(mskx, rr.minSz);
    mskx = imfill(mskx, 'holes');
    cc = bwconncomp(mskx);
    ccSz = cellfun(@numel, cc.PixelIdxList);
    cc.PixelIdxList = cc.PixelIdxList(ccSz <= rr.maxSz);
    cc.NumObjects = numel(cc.PixelIdxList);
    mskx = labelmatrix(cc);
    bLst = bwboundaries(mskx > 0);

    % save mask
    rr.mask = mskx;
    bdMsk{ix} = rr;
    bd('maskLst') = bdMsk;
    setappdata(f, 'bd', bd);

    % get boundary
    mskb = zeros(H, W);

    for ii = 1:numel(bLst)
        ix = bLst{ii};
        ix = sub2ind([H, W], ix(:, 1), ix(:, 2));
        mskb(ix) = 1;
    end 

    d1 = datAvg;
    d1(mskb>0) = d1(mskb>0)*0.7+mskb(mskb>0)*0.5;    
    datx = cat(3, d1, datAvg, datAvg);

    im.CData = datx(end:-1:1,:,:);
    ax.XLim = [1, W];
    ax.YLim = [1, H];

end 
