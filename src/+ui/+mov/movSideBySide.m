function movSideBySide(~,~,f)
fh = guidata(f);
btSt = getappdata(f,'btSt');
col = getappdata(f,'col');
n = round(fh.sldMov.Value);
if ~isfield(btSt,'sbs')
    btSt.sbs = 0;
end
if btSt.sbs==0
    btSt.sbs = 1;
    fh.sbs.BackgroundColor = [0.3 0.3 0.7];
    fh.movTop.Selection = 2;
    fh.pBrightness.Selection = 2;
else
    btSt.sbs = 0;
    fh.sbs.BackgroundColor = col;
    fh.movTop.Selection = 1;
    fh.pBrightness.Selection = 1;
end
setappdata(f,'btSt',btSt);
if n>0
    ui.over.adjMov([],[],f,1)
    ui.movStep(f,n,[],1);
end
end