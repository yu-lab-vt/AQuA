function evtMngrDeleteSel(~,~,f)
fh = guidata(f);
btSt = getappdata(f,'btSt');
tb = fh.evtTable;
dat = tb.Data;
idxGood = [];
for ii=1:size(dat,1)
    if dat{ii,1}==0
        idxGood = union(dat{ii,2},idxGood);
    end
end
btSt.evtMngrMsk = idxGood;
setappdata(f,'btSt',btSt);
ui.evt.evtMngrRefresh([],[],f);
ui.movStep(f);
end