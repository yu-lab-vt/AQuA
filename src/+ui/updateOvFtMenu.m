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

if strcmp(ovName,'Events')
    xxx = 'on';
    fh.overlayFeature.Enable = xxx;
    fh.overlayColor.Enable = xxx;
    fh.overlayTrans.Enable = xxx;
    fh.overlayScale.Enable = xxx;
    fh.overlayPropDi.Enable = xxx;
    fh.overlayLmk.Enable = xxx;
    fh.sldMinOv.Enable = xxx;
    fh.sldMaxOv.Enable = xxx;
end

end
