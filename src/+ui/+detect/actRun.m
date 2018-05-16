function actRun(~,~,f)
% active voxels detection and update overlay map

fprintf('Detecting ...\n')

fh = guidata(f);
ff = waitbar(0,'Detecting ...');

bd = getappdata(f,'bd');
% dF = getappdata(f,'dF');
datOrg = getappdata(f,'datOrg');
opts = getappdata(f,'opts');

% only inside user drawn cells
sz = opts.sz;
evtSpatialMask = ones(sz(1),sz(2));
if bd.isKey('cell')
    bd0 = bd('cell');
    evtSpatialMask1 = zeros(sz(1),sz(2));
    for ii=1:numel(bd0)
        p0 = bd0{ii}{1};
        msk0 = poly2mask(p0(:,1),p0(:,2),sz(2),sz(1));
        spaMsk0 = msk0;
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

[dat,dF,arLst,lmLoc,opts] = burst.actTop(datOrg,opts,evtSpatialMask,ff);
% [arLst,lmLoc] = burst.actTop(dat,dF,opts,evtSpatialMask,ff);
waitbar(1,ff);

setappdata(f,'dat',dat);
setappdata(f,'dF',dF);
setappdata(f,'arLst',arLst);
setappdata(f,'lmLoc',lmLoc);
setappdata(f,'opts',opts);

ui.detect.postRun([],[],f,arLst,[],'Step 1: active voxels');

delete(ff);
fprintf('Done\n')

end





