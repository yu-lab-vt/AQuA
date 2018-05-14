function updateOvFtMenu(~,~,f)
% updateOvFtMenu update the overlay data type
% only useful when each step of event detection finished

fh = guidata(f);

btSt = getappdata(f,'btSt');
dSel = btSt.overlayDatSel;

ov = getappdata(f,'ov');

ovName = ov.keys;
k = strfind(ovName,dSel);
idx = find(cellfun(@isempty,k)==0,1); %#ok<STRCLFH>

fh.overlayDat.String = ovName;
fh.overlayDat.Value = idx;

ui.over.chgOv([],[],f,1);

end
