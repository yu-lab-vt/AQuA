function zsRun(~,~,f)
% z scores and filtering

fprintf('Detecting ...\n')

fh = guidata(f);
ff = waitbar(0,'Cleaning ...');

% dat = getappdata(f,'dat');
opts = getappdata(f,'opts');
evtLst = getappdata(f,'evtLstAll');
riseLst = getappdata(f,'riseLstAll');
dffMat = getappdata(f,'dffMatAll');
ftsLst = getappdata(f,'ftsLstAll');
datR = getappdata(f,'datRAll');

try
    opts.zThr = str2double(fh.zThr.String);
    setappdata(f,'opts',opts);
catch
    msgbox('Error setting parameters')
end

% [ftsLst,dffMat] = fea.getFeatureQuick(dat,evtLst,opts);
mskx = ftsLst.curve.dffMaxZ>=opts.zThr;
evtLstFilterZ = evtLst(mskx);
dffMatFilterZ = dffMat(mskx,:);
tBeginFilterZ = ftsLst.curve.tBegin(mskx);
riseLstFilterZ = riseLst(mskx);

setappdata(f,'evtLstFilterZ',evtLstFilterZ);
setappdata(f,'dffMatFilterZ',dffMatFilterZ);
setappdata(f,'tBeginFilterZ',tBeginFilterZ);
setappdata(f,'riseLstFilterZ',riseLstFilterZ);

waitbar(1,ff);

ui.detect.postRun([],[],f,evtLstFilterZ,datR,'Step 4: events cleaned');

fh.nEvt.String = num2str(numel(evtLstFilterZ));
delete(ff);
fprintf('Done\n')

end





