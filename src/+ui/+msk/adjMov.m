function adjMov(~,~,f)
    
    fh = guidata(f);
    tbDat = cell2mat(fh.mskTable.Data(:,1));
    if isempty(tbDat)
        return
    end
    
    ix = find(tbDat,1);
    bd = getappdata(f,'bd');
    bdMsk = bd('maskLst');
    rr = bdMsk{ix};
    
    rr.thr = fh.sldMskThr.Value;
    rr.minSz = round(10^(fh.sldMskMinSz.Value));
    rr.maxSz = round(10^(fh.sldMskMaxSz.Value));
    
    bdMsk{ix} = rr;
    bd('maskLst') = bdMsk;
    setappdata(f,'bd',bd);
    
    ui.msk.viewImgMsk([],[],f);
    ui.msk.updtMskSld([],[],f,rr);
    
end