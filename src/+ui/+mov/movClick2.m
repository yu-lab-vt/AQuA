function movClick2(~,evtDat,f,~,lbl)
% get cursor location and run operation specified by op when click movie
%
% Note the difference between image cooridate and matrix coordinate
% For 512 by 512 image, (1,1) in matrix is (1,512) in movie
% Image object begin with (0.5,0.5) to (512.5,512.5)

    fh = guidata(f);
    tb = fh.mskTable;
    im = fh.imsMsk;
    opts = getappdata(f,'opts');
    sz = opts.sz;

    xy = evtDat.IntersectionPoint;
    x = max(round(xy(1)),1);
    y = max(round(xy(2)),1);

    % remove drawn regions
    bd = getappdata(f,'bd');
    xrg = max(x-1,1):min(x+1,sz(2));
    yrg = max(y-1,1):min(y+1,sz(1));

    bdMsk = bd(lbl);
    dat = tb.Data;
    idx = cell2mat(dat(:,1));
    idx = find(idx>0);
    rr = bdMsk{idx};
    
    cc = bwconncomp(rr.mask);
    pix = cc.PixelIdxList;
    msk = false(size(rr.datAvg));
    datAvg = rr.datAvg;
    [H, W] = size(datAvg);
    
    for ii=1:numel(pix)
        pix0 = pix{ii};
        map00 = zeros(H,W);
        map00(pix0) = 1;
        map01 = flipud(map00);
        %map00 = bd0{ii}{2};
        %map00 = poly2mask(x00(:,1),x00(:,2),sz(1),sz(2));
        v00 = map01(yrg,xrg);
        if sum(v00(:))==0
            msk = msk|map00;
        end
    end
    
    rr.mask = msk;
    bdMsk{idx} = rr;
    bd(lbl) = bdMsk;
    setappdata(f,'bd',bd);
    
%     ui.msk.updtMskSld([],[],f,rr);
%     ui.msk.viewImgMsk([],[],f);  % update image


    bLst = bwboundaries(rr.mask > 0);
    
     % get boundary for drawing
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


