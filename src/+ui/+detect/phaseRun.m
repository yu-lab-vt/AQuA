function phaseRun(~,~,f)
% active voxels detection and update overlay map

fprintf('Detecting ...\n')

fh = guidata(f);
ff = waitbar(0,'Detecting ...');

dF = getappdata(f,'dF');
dat = getappdata(f,'dat');
opts = getappdata(f,'opts');
lmLoc = getappdata(f,'lmLoc');
bd = getappdata(f,'bd');

sz = opts.sz;
evtSpatialMask = ones(sz(1),sz(2));
if bd.isKey('cell')
    bd0 = bd('cell');
    evtSpatialMask = zeros(sz(1),sz(2));
    for ii=1:numel(bd0)
        p0 = bd0{ii}{2};
        spaMsk0 = zeros(sz(1),sz(2));
        spaMsk0(p0) = 1;
        evtSpatialMask(spaMsk0>0) = 1;
    end
end

try
    opts.thrTWScl = str2double(fh.thrTWScl.String);
    opts.thrExtZ = str2double(fh.thrExtZ.String);
    setappdata(f,'opts',opts);
catch
    msgbox('Error setting parameters')
end

if isfield(opts,'skipSteps') && opts.skipSteps>0
    svLst = getappdata(f,'arLst');
    riseX = [];
else
    % grow seeds
    [svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,evtSpatialMask,opts,ff);
end

% save data
setappdata(f,'svLst',svLst);
setappdata(f,'riseX',riseX);

ui.detect.postRun([],[],f,svLst,[],'Step 2: super voxels');

delete(ff);
fprintf('Done\n')

end





