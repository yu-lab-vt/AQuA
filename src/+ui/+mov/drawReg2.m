function drawReg2(~,~,f,op,lbl)
    % updtFeature update network features after user draw regions
    
    fh = guidata(f);
    ax = fh.movBuilder;
    tb = fh.mskTable;
    im = fh.imsMsk;
    
    bd = getappdata(f,'bd');
    bdMsk = bd('maskLst');
    
    dat = tb.Data;
    idx = cell2mat(dat(:,1));
    idx = find(idx>0);
    rr = bdMsk{idx};
    msk = false(size(rr.datAvg));
    
    if strcmp(op,'add')
        tmp = [];
        hh = impoly(ax);
        if ~isempty(hh)
            nPts = size(hh.getPosition,1);
            if nPts>2
                msk = flipud(hh.createMask);
                tmp{1} = bwboundaries(msk);
                tmp{2} = find(msk>0);
                tmp{3} = 'manual';
                delete(hh)
            end
        end
    end

    rr.mask = rr.mask|msk;
    bdMsk{idx} = rr;
    bd(lbl) = bdMsk;
    setappdata(f,'bd',bd);
    
%     ui.msk.updtMskSld([],[],f,rr);
%     ui.msk.viewImgMsk([],[],f);  % update image


    bLst = bwboundaries(rr.mask > 0);
    datAvg = rr.datAvg;
    [H, W] = size(datAvg);
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







