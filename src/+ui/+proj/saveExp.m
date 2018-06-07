function res = saveExp(~,~,f,file0,path0,modex)
% saveExp save experiment (and export results)

fts = getappdata(f,'fts');
if ~exist('modex','var')
    modex = 0;
end
if isempty(fts)
    msgbox('Please save after event detection\n');
    return
end
if ~exist(path0,'file') && ~isempty(path0)
    mkdir(path0);    
end


%% gather results
ff = waitbar(0,'Gathering results ...');

% if do not want to detect again, do not need to save dF
vSave0 = {...  % basic variables for results analysis
    'opts','scl','btSt','ov','bd','datOrg','evt','fts','dffMat','dMat',...
    'riseLst','featureTable','userFeatures'...
    };
% vSave1 = {...  % extra variables for event detection
%     'arLst','lmLoc','svLst','riseX','riseLstAll','evtLstAll','ftsLstAll',...
%     'dffMatAll','datRAll','evtLstFilterZ','dffMatFilterZ','tBeginFilterZ',...
%     'riseLstFilterZ','evtLstMerge','dF'...
% };
% vSave = [vSave0,vSave1];
vSave = vSave0;

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
res.evtFilter = res.evt(xSel);
res.dffMatFilter = res.dffMat(xSel,:,:);
if ~isempty(res.dMat)
    res.dMatFilter = res.dMat(xSel,:,:);
end
if ~isempty(res.riseLst)  % rising map is for super events
    res.riseLstFilter = res.riseLst(xSel);
end
res.evtSelectedList = find(xSel>0);

% save raw movie with 8 or 16 bits to save space
res.opts.bitNum = 16;
res.maxVal = nanmax(res.datOrg(:));  
res.datOrg = res.datOrg/res.maxVal;
dat1 = res.datOrg*(2^res.opts.bitNum-1);
res.datOrg = uint16(dat1);

res.stg.post = 1;
res.stg.detect = 1;

if modex>0
    waitbar(1,ff);
    delete(ff);
    return
end

%% export
waitbar(0.25,ff,'Saving ...');
btSt = getappdata(f,'btSt');
favEvtLst = btSt.evtMngrMsk;
fout = [path0,filesep,file0];
[fpath,fname,ext] = fileparts(fout);

if isempty(ext)
    fout = [fout,'.mat'];
end
save(fout,'res','-v7.3');

waitbar(0.5,ff,'Writing movie ...');

fh = guidata(f);
opts = getappdata(f,'opts');

% export movie
if fh.expMov.Value==1
    ov1 = zeros(opts.sz(1),opts.sz(2),3,opts.sz(3));
    for tt=1:opts.sz(3)
        if mod(tt,100)==0
            fprintf('Frame %d\n',tt); 
        end
        ov1(:,:,:,tt) = ui.movStep(f,tt,1);
    end
    ui.movStep(f);
    fmov = [fpath,filesep,fname,'.tif'];
    io.writeTiffSeq(fmov,ov1,8);
end

% export feature table
ftTb = getappdata(f,'featureTable');
if isempty(ftTb)
    ui.detect.getFeatureTable(f);
    ftTb = getappdata(f,'featureTable');
end
cc = ftTb{:,1};

% all selected events
cc1 = cc(:,xSel);
ftTb1 = table(cc1,'RowNames',ftTb.Row);
ftb = [fpath,filesep,fname,'.xlsx'];
writetable(ftTb1,ftb,'WriteVariableNames',0,'WriteRowNames',1);

% for each region
if ~isempty(fts.region) && isfield(fts.region.cell,'memberIdx') && ~isempty(fts.region.cell.memberIdx)
    memSel = fts.region.cell.memberIdx(xSel,:);
    for ii=1:size(memSel,2)
        mem00 = memSel(:,ii);
        cc00 = cc(:,mem00>0);
        ftTb00 = table(cc00,'RowNames',ftTb.Row);
        ftb00 = [fpath,filesep,fname,'_region_',num2str(ii),'.xlsx'];
        writetable(ftTb00,ftb00,'WriteVariableNames',0,'WriteRowNames',1);
    end
end

% for favorite events
if ~isempty(favEvtLst)
    cc00 = cc(:,favEvtLst);
    ftTb00 = table(cc00,'RowNames',ftTb.Row);
    ftb00 = [fpath,filesep,fname,'_favorite.xlsx'];
    writetable(ftTb00,ftb00,'WriteVariableNames',0,'WriteRowNames',1);
end

% region and landmark map
f00 = figure('Visible','off');
dat = getappdata(f,'datOrg');
dat = mean(dat,3);
dat = dat/max(dat(:));
Low_High = stretchlim(dat,0.001);
dat = imadjust(dat,Low_High);
axNow = axes(f00);
image(axNow,'CData',flipud(dat),'CDataMapping','scaled');
axNow.XTick = [];
axNow.YTick = [];
axNow.XLim = [0.5,size(dat,2)+0.5];
axNow.YLim = [0.5,size(dat,1)+0.5];
axNow.DataAspectRatio = [1 1 1];
colormap gray
ui.mov.addPatchLineText(f,axNow,0,1)
% saveas(f00,[fpath,filesep,fname,'_landmark.fig']);
saveas(f00,[fpath,filesep,fname,'_landmark.png'],'png');
delete(f00);

% rising maps
riseLst = getappdata(f,'riseLst');
if ~isempty(favEvtLst)
    f00 = figure('Visible','off');
    axNow = axes(f00);
    fpathRising = [fpath,filesep,'risingMaps'];
    if ~exist(fpathRising,'file')
        mkdir(fpathRising);
    end
    for ii=1:numel(favEvtLst)
        rr = riseLst{favEvtLst(ii)};
        imagesc(axNow,rr.dlyMap);
        colorbar(axNow);
        xx = axNow.XTickLabel;
        for jj=1:numel(xx)
            xx{jj} = num2str(str2double(xx{jj})+min(rr.rgw)-1);
        end
        axNow.XTickLabel = xx;
        xx = axNow.YTickLabel;
        for jj=1:numel(xx)
            xx{jj} = num2str(str2double(xx{jj})+min(rr.rgw)-1);
        end
        axNow.YTickLabel = xx;
        axNow.DataAspectRatio = [1 1 1];
        saveas(f00,[fpathRising,filesep,num2str(favEvtLst(ii)),'.png'],'png');
    end
end

delete(ff);

end







