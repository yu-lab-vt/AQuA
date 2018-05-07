function evtMngrShowCurve(~,~,f)
fh = guidata(f);
tb = fh.evtTable;
dat = tb.Data;
idxGood = [];
for ii=1:size(dat,1)
    if dat{ii,1}==1
        idxGood = union(dat{ii,2},idxGood);
    end
end
if ~isempty(idxGood)
    ui.evt.curveRefresh([],[],f,idxGood);
end
end