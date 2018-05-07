function stepOne(~,~,f)
fh = guidata(f);
n = round(fh.sldMov.Value);
ui.movStep(f,n);
end