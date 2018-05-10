function showRisingMap(f,imName,n)

btSt = getappdata(f,'btSt');
evtLst = btSt.evtMngrMsk;

fts = getappdata(f,'fts');
t0 = fts.loc.t0;
t1 = fts.loc.t1;
mskx = false(numel(t0),1);
mskx(evtLst) = true;
evtSel = find(mskx & t0(:)<=n & t1(:)>=n);

opts = getappdata(f,'opts');
sz = opts.sz;
riseMapCol = ones(sz(1)*sz(2),3);
fh = guidata(f);

if ~isempty(evtSel)
    riseLst = getappdata(f,'riseLst');
    riseMap = nan(sz(1),sz(2));
    try
        for ii=1:numel(evtSel)
            rr = riseLst{evtSel(ii)};
            riseMap(rr.rgh,rr.rgw) = nanmax(rr.dlyMap,riseMap(rr.rgh,rr.rgw));
        end
    catch
        msgbox('Rising map not found')
        return
    end
    
    jm = jet(1000);
    rs = riseMap(~isnan(riseMap(:)));
    if max(rs)>min(rs)
        rs = round((rs-min(rs))/(max(rs)-min(rs))*999+1);
    else
        rs = rs*0+500;
    end
    rs = max(min(rs,1000),1);
    rsCol = jm(rs,:);

    riseMapCol(~isnan(riseMap(:)),:) = rsCol;
    riseMapCol = reshape(riseMapCol,sz(1),sz(2),3);
    
    % rising map
    fh.ims.(imName).CData = flipud(riseMapCol);
    
    switch imName
        case 'im2a'
            axNow = fh.movLColMap;
        case 'im2b'
            axNow = fh.movRColMap;
    end
    
    % color map
    rs = riseMap(~isnan(riseMap(:)));
    gap0 = (max(rs)-min(rs))/99;
    if gap0>0
        m0 = min(rs):gap0:max(rs);
    else
        m0 = zeros(1,100)+rs(1);
    end
    
    cMap1 = jet(numel(m0));
    ui.over.updtColMap(axNow,m0,cMap1,1);    
else
    fh.ims.(imName).CData = flipud(riseMapCol);    
end

end



























