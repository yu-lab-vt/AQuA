function showRisingMap(f,imName,n)

btSt = getappdata(f,'btSt');
evtLst = btSt.evtMngrMsk;

fts = getappdata(f,'fts');
t0 = fts.loc.t0;
t1 = fts.loc.t1;
mskx = false(numel(t0),1);
mskx(evtLst) = true;
evtSel = find(mskx & t0(:)<=n & t1(:)>=n);
if isempty(evtSel)
    return
end

riseLst = getappdata(f,'riseLst');
opts = getappdata(f,'opts');
sz = opts.sz;
riseMap = nan(sz(1),sz(2));
for ii=1:numel(evtSel)
    rr = riseLst{evtSel(ii)};
    riseMap(rr.rgh,rr.rgw) = nanmax(rr.dlyMap,riseMap(rr.rgh,rr.rgw));
end

% tMin = nanmin(riseMap(:));
% tMax = nanmax(riseMap(:));

jm = jet(1000);
rs = riseMap(~isnan(riseMap(:)));
if max(rs)>min(rs)
    rs = round((rs-min(rs))/(max(rs)-min(rs))*999+1);
else
    rs = rs*0+500;
end
rs = max(min(rs,1000),1);
rsCol = jm(rs,:);

riseMapCol = ones(sz(1)*sz(2),3);
riseMapCol(~isnan(riseMap(:)),:) = rsCol;
riseMapCol = reshape(riseMapCol,sz(1),sz(2),3);

% clean all patchesc
fh = guidata(f);
fh.(imName).CData = flipud(riseMapCol);

end






