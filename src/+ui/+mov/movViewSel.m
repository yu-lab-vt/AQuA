function movViewSel(~,~,f)
fh = guidata(f);
btSt = getappdata(f,'btSt');
n = round(fh.sldMov.Value);
if ~isfield(btSt,'sbs')
    btSt.sbs = 0;
    btSt.leftView = 'Raw + overlay';
    btSt.rightView = 'Raw';
end
if btSt.sbs==1
    btSt.leftView = fh.movLType.String{fh.movLType.Value};
    btSt.rightView = fh.movRType.String{fh.movRType.Value};
end
setappdata(f,'btSt',btSt);
if n>0
    try
        ui.movStep(f,n,[],1);
    catch
    end
end
end