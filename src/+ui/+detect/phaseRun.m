function phaseRun(~,~,f)
% active voxels detection and update overlay map

fprintf('Detecting ...\n')

fh = guidata(f);
ff = waitbar(0,'Detecting ...');
% fh.wkflPhaseRun.Enable = 'off'; pause(0.1)

dF = getappdata(f,'dF');
% dL = getappdata(f,'dL');
dat = getappdata(f,'dat');
% datSmo = getappdata(f,'datSmo');
opts = getappdata(f,'opts');
lmLoc = getappdata(f,'lmLoc');
% lmLocR = getappdata(f,'lmLocR');
% lmAll = getappdata(f,'lmAll');

try
    opts.thrTWScl = str2double(fh.thrTWScl.String);
    opts.thrExtZ = str2double(fh.thrExtZ.String);
    setappdata(f,'opts',opts);
catch
    msgbox('Error setting parameters')
end

% grow seeds
[lblMapS,~,~,riseMap] = burst.spTop(dat,dF,lmLoc,opts,ff);

% save data
setappdata(f,'lblMapS',lblMapS);
setappdata(f,'riseMap',riseMap);
% setappdata(f,'riseX',riseX);

% overlays object
ov = getappdata(f,'ov');
ov0 = ui.over.getOv(label2idx(lblMapS),size(lblMapS));
ov0.name = 'Super pixels';
ov0.colorCodeType = {'Random'};
ov(ov0.name) = ov0;
setappdata(f,'ov',ov);

% update UI
btSt = getappdata(f,'btSt');
btSt.overlayDatSel = 'Super pixels';
btSt.overlayColorSel = 'Random';
setappdata(f,'btSt',btSt);
ui.over.updateOvFtMenu([],[],f);

% show movie with overlay
ui.movStep(f);


% fh.wkflPhaseRun.Enable = 'on';
fh.pEvt.Visible = 'on';
delete(ff);
fprintf('Done\n')

end





