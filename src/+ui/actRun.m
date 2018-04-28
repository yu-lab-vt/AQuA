function actRun(~,~,f)
% active voxels detection and update overlay map

fprintf('Detecting ...\n')

fh = guidata(f);
fh.wkflActRun.Enable = 'off';
% set(f,'pointer','watch');
pause(0.1)

dF = getappdata(f,'dF');
dat = getappdata(f,'dat');
opts = getappdata(f,'opts');

try
    opts.thrARScl = str2double(fh.thrArScl.String);
    opts.smoXY = str2double(fh.smoXY.String);
    opts.minSize = str2double(fh.minSize.String);
    setappdata(f,'opts',opts);
catch
    msgbox('Error setting parameters')
end

try
    % [dat,datSmo,dL,lmAll,lmLoc] = burst.actTop(dat,dF,opts);
    %[dat,datSmo,dL,arLst,lmLoc,lmLocR] = burst.actTop(dat,dF,opts);
    [arLst,lmLoc] = burst.actTop(dat,dF,opts);
    
    % overlays object
    ov = getappdata(f,'ov');
    ov0 = ui.getOv(arLst,size(dat));
    ov0.name = 'Active voxels';
    ov0.colorCodeType = {'Random'};
    ov(ov0.name) = ov0;
    setappdata(f,'ov',ov);
    
    %setappdata(f,'dat',dat);
    %setappdata(f,'dL',dL);
    %setappdata(f,'datSmo',datSmo);
    setappdata(f,'arLst',arLst);
    %setappdata(f,'lmLocR',lmLocR);
    setappdata(f,'lmLoc',lmLoc);
    
    % update UI
    btSt = getappdata(f,'btSt');
    btSt.overlayDatSel = 'Active voxels';
    btSt.overlayColorSel = 'Random';
    setappdata(f,'btSt',btSt);
    ui.updateOvFtMenu([],[],f);
    
    % show movie with overlay
    ui.movStep(f);
catch ME
    fh.wkflActRun.Enable = 'on';
    rethrow(ME)
end

fh.wkflActRun.Enable = 'on';
fh.pPhase.Visible = 'on';

fprintf('Done\n')

end





