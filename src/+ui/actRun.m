function actRun(~,~,f)
% active voxels detection and update overlay map

fprintf('Detecting ...\n')

fh = guidata(f);
ff = waitbar(0,'Detecting ...');

% fh.wkflActRun.Enable = 'off';
% pause(0.1)

bd = getappdata(f,'bd');
dF = getappdata(f,'dF');
dat = getappdata(f,'dat');
opts = getappdata(f,'opts');

sz = opts.sz;
evtSpatialMask = ones(sz(1),sz(2));
if bd.isKey('cell')
    bd0 = bd('cell');
    evtSpatialMask1 = zeros(sz(1),sz(2));
    for ii=1:numel(bd0)
        spaMsk0 = bd0{ii}{2};
        evtSpatialMask1(spaMsk0>0) = 1;
    end
    if sum(evtSpatialMask1(:))>0
        evtSpatialMask = flipud(evtSpatialMask1);
    end
end

try
    opts.thrARScl = str2double(fh.thrArScl.String);
    opts.smoXY = str2double(fh.smoXY.String);
    opts.minSize = str2double(fh.minSize.String);
    setappdata(f,'opts',opts);
catch
    msgbox('Error setting parameters')
end

% [dat,datSmo,dL,lmAll,lmLoc] = burst.actTop(dat,dF,opts);
%[dat,datSmo,dL,arLst,lmLoc,lmLocR] = burst.actTop(dat,dF,opts);
[arLst,lmLoc] = burst.actTop(dat,dF,opts,evtSpatialMask,ff);
waitbar(1,ff);

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

% fh.wkflActRun.Enable = 'on';
fh.pPhase.Visible = 'on';
delete(ff);
fprintf('Done\n')

end





