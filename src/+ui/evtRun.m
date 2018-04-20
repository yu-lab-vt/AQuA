function evtRun(~,~,f)
% active voxels detection and update overlay map

fprintf('Detecting ...\n')

fh = guidata(f);
fh.wkflEvtRun.Enable = 'off'; pause(0.1)

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
    opts.cOver = str2double(fh.cOver.String);
    opts.evtGtwSmo = str2double(fh.evtGtwSmo.String);
    opts.mergeEventDiscon = str2double(fh.mergeEventDiscon.String);
    setappdata(f,'opts',opts);
catch
    msgbox('Error setting parameters')
end

try
    [fts,evt,dffMat,riseLst,dRecon,lblMapE] = burst.evtTop(dat,dF,lblMapS,riseMap,opts);
    %[fts,evt,dffMat,dMat,dRecon,~,~,lblMapE] = burst.evtTop(...
    %    dat,datSmo,dF,dL,lblMapS,riseMap,opts);
    
    % save data
    setappdata(f,'evt',evt);
    setappdata(f,'fts',fts);
    setappdata(f,'riseLst',riseLst);
    setappdata(f,'dffMat',dffMat);
    setappdata(f,'dMat',dMat);
    
    % overlays object
    ov = getappdata(f,'ov');
    ov0 = ui.getOv(label2idx(lblMapE),size(lblMapE),dRecon);
    ov0.name = 'Events';
    ov0.colorCodeType = {'Random'};
    ov(ov0.name) = ov0;
    setappdata(f,'ov',ov);
    
    % network features
    ui.updtFeature([],[],f);
    
    % update UI
    btSt = getappdata(f,'btSt');
    btSt.overlayDatSel = 'Events';
    btSt.overlayColorSel = 'Random';
    setappdata(f,'btSt',btSt);
    ui.updateOvFtMenu([],[],f);
    
    ui.chgOv([],[],f,1)
    
    % show movie with overlay
    ui.movStep(f);
    
    % filter table init
    ui.filterInit([],[],f);
catch ME
    fh.wkflEvtRun.Enable = 'on';
    rethrow(ME)
end

fh.wkflEvtRun.Enable = 'on';
fh.pFilter.Visible = 'on';
fh.pEvtMngr.Visible = 'on';
fh.pExport.Visible = 'on';
fh.pSys.Visible = 'on';
fprintf('Done\n')

end





