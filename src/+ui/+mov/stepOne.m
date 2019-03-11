function stepOne(~,~,f)
fh = guidata(f);
n = round(fh.sldMov.Value);
ui.movStep(f,n,[]);
if(isfield(fh,'showcurves'))
    evtIdx = fh.showcurves;
    if ~isempty(evtIdx)
        ui.evt.curveRefresh([],[],f,evtIdx);
    end
end
end