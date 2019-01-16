function stepOne(~,~,f)
fh = guidata(f);
n = round(fh.sldMov.Value);
ui.movStep(f,n,[]);
evtIdx = fh.showcurves;
if ~isempty(evtIdx)
    ui.evt.curveRefresh([],[],f,evtIdx);
end
end