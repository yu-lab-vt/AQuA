function updtFeature(~,~,f)
% updtFeature update network features after user draw regions
% regions are all in x,y coordinate, where y need to be flipped for matrix manipulation

thrxx = 0;  % FIXME let user adjust threshold

fprintf('Updating network, region and landmark features\n')

ff = waitbar(0,'Updating features ...');

% % remove appdatas
% var2Rm = {'dF','datSmo','lblMapS','dL'};
% for ii=1:numel(var2Rm)
%     var0 = var2Rm{ii};
%     if isappdata(f,var0)
%         rmappdata(f,var0);
%     end
% end
% fh = guidata(f);
% fh.wkflEvtRun.Enable = 'off'; 
% fh.wkflPhaseRun.Enable = 'off';

% read data
ov = getappdata(f,'ov');
opts = getappdata(f,'opts');
btSt = getappdata(f,'btSt');
bd = getappdata(f,'bd');

sz = opts.sz;
fm = btSt.filterMsk;

% polygons
if bd.isKey('cell')
    bd0 = bd('cell');
    evtSpatialMask = zeros(sz(1),sz(2));
    regLst = cell(numel(bd0),1);
    for ii=1:numel(bd0)
        regLst{ii} = bd0{ii}{1};
        spaMsk0 = bd0{ii}{2};
        evtSpatialMask(spaMsk0>0) = 1;
    end
else
    regLst = [];
    evtSpatialMask = ones(sz(1),sz(2));
end
if bd.isKey('landmk')
    bd1 = bd('landmk');
    lmkLst = cell(numel(bd1),1);
    %lmkMsk = cell(numel(bd1),1);
    for ii=1:numel(bd1)
        lmkLst{ii} = bd1{ii}{1};
        %lmkMsk{ii} = bd1{ii}{2};
    end
else
    lmkLst = [];
end

% choose bright part for propagation calculation
fprintf('Gathering data ...\n')
ov0 = ov('Events');
evtMap = zeros(sz,'uint32');
lblMapE = zeros(sz,'uint32');
dRecon = zeros(sz,'single');
for tt=1:sz(3)
    tmp = zeros(sz(1),sz(2));
    tmpAll = zeros(sz(1),sz(2));
    ov00 = ov0.frame{tt};
    if isempty(ov00)
        continue
    end
    for ii=1:numel(ov00.idx)
        idx00 = ov00.idx(ii);
        pix00 = ov00.pix{ii};
        val00 = ov00.val{ii};
        tmp(pix00(val00>thrxx)) = idx00;
        tmpAll(pix00) = idx00;
        dRecon(pix00) = single(val00);
    end
    evtMap(:,:,tt) = uint32(tmp);
    lblMapE(:,:,tt) = uint32(tmpAll);
end

% basic features
waitbar(0.5,ff);
if 1
    fprintf('Updating basic features ...\n')
    dat = getappdata(f,'dat');
    [evt,fts,dffMat,dMat] = burst.getFeaturesTop(dat,lblMapE,dRecon,opts);
    setappdata(f,'evt',evt);
    setappdata(f,'dffMat',dffMat);
    setappdata(f,'dMat',dMat);
else
    fts = getappdata(f,'fts');
end

% only use events inside region and is filtered
% update network features, all filtered events
evtx = label2idx(evtMap);
clear evtMap
if ~isempty(fm)
    for ii=1:numel(evtx)
        if fm(ii)==0
            evtx{ii} = [];
        end
    end
end
fts.networkAll = burst.getEvtNetworkFeatures(evtx,sz);

% events inside cells only
if ~isempty(regLst)
    for ii=1:numel(evtx)
        if isfield(fts,'loc2D')
            loc00 = fts.loc2D{ii};
        else
            loc00 = fts.loc.x2D{ii};
        end
        if sum(evtSpatialMask(loc00))==0
            evtx{ii} = [];
        end
    end
end
fts.network = burst.getEvtNetworkFeatures(evtx,sz);

% update features
waitbar(0.75,ff);
if ~isempty(regLst) || ~isempty(lmkLst)
    fprintf('Updating region and landmark features ...\n')
    %fts.lmk = burst.getDistRegionBorderMIMO(evtx,regLst,lmkLst,sz);
    fts.region = burst.getDistRegionBorderMIMO(evtx,dRecon,regLst,lmkLst);
else
    fts.region = [];
end
setappdata(f,'fts',fts);

% update events to show
waitbar(1,ff);
if ~isempty(regLst)
    btSt.regMask = sum(fts.region.cell.memberIdx>0,2);
else
    btSt.regMask = ones(numel(fts.loc.x3D),1);
end
setappdata(f,'btSt',btSt);
ui.updtEvtOvShowLst([],[],f);

fprintf('Done.\n')
delete(ff)

end







