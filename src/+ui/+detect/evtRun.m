function evtRun(~,~,f)
% active voxels detection and update overlay map

fprintf('Detecting ...\n')

fh = guidata(f);
ff = waitbar(0,'Detecting ...');

svLst = getappdata(f,'svLst');
riseX = getappdata(f,'riseX');
dat = getappdata(f,'dat');
dF = getappdata(f,'dF');
opts = getappdata(f,'opts');

try
    opts.cRise = str2double(fh.cRise.String);
    opts.cDelay = str2double(fh.cDelay.String);
    opts.gtwSmo = str2double(fh.gtwSmo.String);
    setappdata(f,'opts',opts);
catch
    msgbox('Error setting parameters')
end

if isfield(opts,'skipSteps') && opts.skipSteps>0
    evtLst = svLst;
    seLst = evtLst;
    datR = 255*ones(size(dat));
    riseLst = cell(0);
    H = opts.sz(1);
    W = opts.sz(2);
    for i = 1:numel(evtLst)
        rr = [];
        rr.dlyMap = zeros(H,W);
        rr.rgh = 1:H;
        rr.rgw = 1:W;
        riseLst{i} = rr;
    end
else
    [riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts,ff);
end

[ftsLst,dffMat] = fea.getFeatureQuick(dat,evtLst,opts);

setappdata(f,'riseLstAll',riseLst);
setappdata(f,'seLstAll',seLst);
setappdata(f,'evtLstAll',evtLst);
setappdata(f,'ftsLstAll',ftsLst);
setappdata(f,'dffMatAll',dffMat);
setappdata(f,'datRAll',datR);

ui.detect.postRun([],[],f,seLst,datR,'Step 3a: super events');
ui.detect.postRun([],[],f,evtLst,datR,'Step 3b: events all');

fh.nEvt.String = num2str(numel(evtLst));
fprintf('Done\n')
delete(ff);

end





