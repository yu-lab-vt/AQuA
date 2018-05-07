function curveRefresh(~,~,f,evtIdxVec)
% curveRefresh draw single or multiple dff curves

fh = guidata(f);
dffMat = getappdata(f,'dffMat');
fts = getappdata(f,'fts');
opts = getappdata(f,'opts');
sz = opts.sz;

ofstGap = 0.3;

xx = double(reshape((dffMat(evtIdxVec,:,2)),numel(evtIdxVec),[]));
xxMin = min(xx(:));
xxMax = max(xx(:))+ofstGap*(numel(evtIdxVec)-1);
xxRg = xxMax-xxMin;

ax = fh.curve;
ax.XLim = [0,sz(3)];
ax.YLim = [xxMin-xxRg*0.1,xxMax+xxRg*0.2];

% delete existing curves
hh = findobj(ax,'Type','line');
delete(hh);
hh = findobj(ax,'Type','text');
delete(hh);

% draw new curves
for ii=1:numel(evtIdxVec)
    evtIdx = evtIdxVec(ii);
    t0 = fts.curve.tBegin(evtIdx);
    t1 = fts.curve.tEnd(evtIdx);
    x = xx(ii,:);
    
    if numel(evtIdxVec)==1
        xAll = dffMat(evtIdx,:,1);
        line(ax,1:sz(3),xAll,'Color',[0.5 0.5 0.5],'LineWidth',1);
        line(ax,1:sz(3),x*0,'Color','k','LineStyle','--');
        line(ax,1:sz(3),x,'Color','b');
        line(ax,t0:t1,x(t0:t1),'Color','r');
    else
        ofst0 = ofstGap*(ii-1);
        x = x + ofst0;
        col = rand(1,3); col = col/sum(col);
        line(ax,1:sz(3),x,'Color',col);
        line(ax,t0:t1,x(t0:t1),'Color',col,'LineWidth',1.5);
    end
    
    xSel = x(t0:t1);
    [xm,ixm] = max(xSel);
    txt0 = [num2str(evtIdx),' dff:',num2str(fts.curve.dffMax(evtIdx))];
    text(ax,ixm+t0-1,xm,txt0);
end

end



