function phaseRun(~,~,f)
% active voxels detection and update overlay map

fprintf('Detecting ...\n')

fh = guidata(f);
ff = waitbar(0,'Detecting ...');

dF = getappdata(f,'dF');
dat = getappdata(f,'dat');
opts = getappdata(f,'opts');
lmLoc = getappdata(f,'lmLoc');

try
    opts.thrTWScl = str2double(fh.thrTWScl.String);
    opts.thrExtZ = str2double(fh.thrExtZ.String);
    setappdata(f,'opts',opts);
catch
    msgbox('Error setting parameters')
end

% grow seeds
[svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,opts,ff);

% save data
setappdata(f,'svLst',svLst);
setappdata(f,'riseX',riseX);

ui.detect.postRun([],[],f,svLst,[],'Step 2: super voxels');

delete(ff);
fprintf('Done\n')

end





