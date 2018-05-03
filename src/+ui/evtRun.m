function evtRun(~,~,f)
% active voxels detection and update overlay map

fprintf('Detecting ...\n')

fh = guidata(f);
ff = waitbar(0,'Detecting ...');

lblMapS = getappdata(f,'lblMapS');
riseMap = getappdata(f,'riseMap');
% riseX = getappdata(f,'riseX');
dat = getappdata(f,'dat');
% datSmo = getappdata(f,'datSmo');
dF = getappdata(f,'dF');
% dL = getappdata(f,'dL');
opts = getappdata(f,'opts');

try
    opts.cRise = str2double(fh.cRise.String);
    opts.cDelay = str2double(fh.cDelay.String);
    %opts.cOver = str2double(fh.cOver.String);
    opts.gtwSmo = str2double(fh.evtGtwSmo.String);
    opts.mergeEventDiscon = str2double(fh.mergeEventDiscon.String);
    setappdata(f,'opts',opts);
catch
    msgbox('Error setting parameters')
end

[riseLst,dRecon,lblMapE] = burst.evtTop(dat,dF,lblMapS,riseMap,opts,ff);

% save data
setappdata(f,'riseLst',riseLst);

% overlays object
ov = getappdata(f,'ov');
ov0 = ui.getOv(label2idx(lblMapE),size(lblMapE),dRecon);
ov0.name = 'Events';
ov0.colorCodeType = {'Random'};
ov(ov0.name) = ov0;
setappdata(f,'ov',ov);

% features
ui.updtFeature([],[],f);
waitbar(1,ff);

% update UI
btSt = getappdata(f,'btSt');
btSt.overlayDatSel = 'Events';
btSt.overlayColorSel = 'Random';
setappdata(f,'btSt',btSt);
ui.updateOvFtMenu([],[],f);

% enable feature overlay
ui.chgOv([],[],f,1)

% show movie with overlay
ui.movStep(f);

% filter table init
ui.filterInit([],[],f);

delete(ff);
fh.updtFeature1.Enable = 'on';
fh.pFilter.Visible = 'on';
fh.pEvtMngr.Visible = 'on';
fh.pExport.Visible = 'on';
fh.pSys.Visible = 'on';
fprintf('Done\n')

end





