function res=saveExp(~,~,f,file0,path0,modex)
% saveExp save experiment (and export results)

fprintf('Saving ...\n')

fts = getappdata(f,'fts');
if ~exist('modex','var')
    modex = 0;
end
if isempty(fts)
    msgbox('Please save after event detection\n');
    return
end

ff = waitbar(0,'Saving ...');

%% save
% variables to save
% vSave = {'opts','scl','btSt','ov','bd','dat'};
vSave = {'opts','scl','btSt','ov','bd','dat','evt','fts','dffMat','dMat','riseLst','featureTable'};
res = [];
for ii=1:numel(vSave)
    v0 = vSave{ii};
    res.(v0) = getappdata(f,v0);
end

% filter features and curves
ov = getappdata(f,'ov');
ov0 = ov('Events');
xSel = ov0.sel;
res.ftsFilter = util.filterFields(fts,xSel);

evt = getappdata(f,'evt');
res.evtFilter = evt(xSel);

dffMat = getappdata(f,'dffMat');
res.dffMatFilter = dffMat(xSel,:,:);

dMat = getappdata(f,'dMat');
if ~isempty(dMat)
    res.dMatFilter = dMat(xSel,:,:);
end

% rising map is for super events
riseLst = getappdata(f,'riseLst');
if ~isempty(riseLst)
    res.riseLstFilter = riseLst;
end

res.evtSelectedList = find(xSel>0);

% save with 16 bit to save space
res.opts.bitNum = 8;
dat1 = res.dat*(2^res.opts.bitNum-1);
if res.opts.bitNum<=8
    res.dat = uint8(dat1);
else
    res.dat = uint16(dat1);
end

res.stg.post = 1;
res.stg.detect = 0;

if modex>0
    waitbar(1,ff);
    delete(ff);
    return
end

%% export
fout = [path0,filesep,file0];
[fpath,fname,ext] = fileparts(fout);
if isempty(ext)
    fout = [fout,'_res.mat'];
end
save(fout,'res');

waitbar(0.5,ff,'Writing movie ...');

fh = guidata(f);
opts = getappdata(f,'opts');

% export movie
if fh.expMov.Value==1
    ov1 = zeros(opts.sz(1),opts.sz(2),3,opts.sz(3));
    for tt=1:opts.sz(3)
        if mod(tt,100)==0; fprintf('Frame %d\n',tt); end
        ov1(:,:,:,tt) = ui.movStep(f,tt,1);
    end
    ui.movStep(f);
    fmov = [fpath,filesep,fname,'.tif'];
    io.writeTiffSeq(fmov,ov1,8);
end

% export feature table
% ftTb = getappdata(f,'featureTable');
% if isempty(ftTb)
%     ui.detect.getFeatureTable(f);
%     ftTb = getappdata(f,'featureTable');
% end
% cc = ftTb{:,1};
% cc = cc(:,xSel);
% ftTb1 = table(cc,'RowNames',ftTb.Row);
% ftb = [fpath,filesep,fname,'_feature.xlsx'];
% writetable(ftTb1,ftb,'WriteVariableNames',0,'WriteRowNames',1);
% fprintf('Done\n')

delete(ff);

end



