function evtReRun(~,~,f)
% active voxels detection and update overlay map

fprintf('Detecting ...\n')
fh = guidata(f);

ff = waitbar(0,'Detecting ...');

riseLstFilterZ = getappdata(f,'riseLstFilterZ');
evtLstFilterZ = getappdata(f,'evtLstFilterZ');
evtLstMerge = getappdata(f,'evtLstMerge');
dat = getappdata(f,'dat');
datR = getappdata(f,'datRAll');
dF = getappdata(f,'dF');

opts = getappdata(f,'opts');
opts.extendEvtRe = fh.extendEvtRe.Value==1;
setappdata(f,'opts',opts);

if isfield(opts,'skipSteps') && opts.skipSteps>0
    riseLstE = riseLstFilterZ; datRE = datR; evtLstE = evtLstFilterZ;
else
    if opts.extendSV==0	|| opts.ignoreMerge==0 || opts.extendEvtRe>0
        [riseLstE,datRE,evtLstE] = burst.evtTopEx(dat,dF,evtLstMerge,opts);
    else
        riseLstE = riseLstFilterZ; datRE = datR; evtLstE = evtLstFilterZ;
    end
end

setappdata(f,'riseLst',riseLstE);
setappdata(f,'evt',evtLstE);

ui.detect.postRun([],[],f,evtLstE,datRE,'Events');

fh.nEvt.String = num2str(numel(evtLstE));

btSt = getappdata(f,'btSt');
btSt.filterMsk = ones(numel(evtLstE),1);
setappdata(f,'btSt',btSt);
    
fprintf('Done\n')
delete(ff);

end





