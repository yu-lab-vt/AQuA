function movGauss(~,~,f)
fh = guidata(f);
btSt = getappdata(f,'btSt');
col = getappdata(f,'col');
n = round(fh.sldMov.Value);
if ~isfield(btSt,'GaussFilter')
    btSt.GaussFilter = 0;
end
if btSt.GaussFilter==0
    btSt.GaussFilter = 1;
    fh.GaussFilter.BackgroundColor = [0.3 0.3 0.7];
else
    btSt.GaussFilter = 0;
    fh.GaussFilter.BackgroundColor = col;
end
setappdata(f,'btSt',btSt);
if n>0
    ui.over.adjMov([],[],f,1)
    ui.movStep(f,n,[],1);
end
end