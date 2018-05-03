function updtFeature(~,~,f)
% updtFeature update network features after user draw regions
% regions are all in x,y coordinate, where y need to be flipped for matrix manipulation

thrxx = 0;  % FIXME let user adjust threshold

fprintf('Updating basic, network, region and landmark features\n')

% read data
ov = getappdata(f,'ov');
opts = getappdata(f,'opts');
btSt = getappdata(f,'btSt');
bd = getappdata(f,'bd');

gg = waitbar(0,'Updating features ...');

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
    for ii=1:numel(bd1)
        lmkLst{ii} = bd1{ii}{1};
    end
else
    lmkLst = [];
end

% reconstruct for propagation calculation
fprintf('Gathering data ...\n')
ov0 = ov('Events');
evtMap = zeros(sz,'uint32');  % binarize for network features
lblMapE = zeros(sz,'uint32');
dRecon = zeros(sz,'uint8');
for tt=1:sz(3)
    tmp = zeros(sz(1),sz(2));
    tmpAll = zeros(sz(1),sz(2));
    ov00 = ov0.frame{tt};
    dRecon00 = zeros(sz(1),sz(2));
    if isempty(ov00)
        continue
    end
    for ii=1:numel(ov00.idx)
        idx00 = ov00.idx(ii);
        pix00 = ov00.pix{ii};
        val00 = ov00.val{ii};
        tmp(pix00(val00>thrxx)) = idx00;
        tmpAll(pix00) = idx00;
        dRecon00(pix00) = uint8(val00*255);
    end
    dRecon(:,:,tt) = dRecon00;
    evtMap(:,:,tt) = uint32(tmp);
    lblMapE(:,:,tt) = uint32(tmpAll);
end

% basic features
waitbar(0.2,gg);
fprintf('Updating basic features ...\n')
dat = getappdata(f,'dat');
[evtLst,ftsLst,dffMat,dMat] = fea.getFeaturesTop(dat,lblMapE,dRecon,opts);
setappdata(f,'evt',evtLst);
setappdata(f,'dffMat',dffMat);
setappdata(f,'dMat',dMat);

% only use events inside region and is filtered
% update network features, all filtered events
waitbar(0.6,gg);
evtx = label2idx(evtMap);
clear evtMap
if ~isempty(fm)
    for ii=1:numel(evtx)
        if fm(ii)==0
            evtx{ii} = [];
        end
    end
end
ftsLst.networkAll = fea.getEvtNetworkFeatures(evtx,sz);

% events inside cells only
if ~isempty(regLst)
    for ii=1:numel(evtx)
        if isfield(ftsLst,'loc2D')
            loc00 = ftsLst.loc2D{ii};
        else
            loc00 = ftsLst.loc.x2D{ii};
        end
        if sum(evtSpatialMask(loc00))==0
            evtx{ii} = [];
        end
    end
end
ftsLst.network = fea.getEvtNetworkFeatures(evtx,sz);

% update features
waitbar(0.7,gg);
if ~isempty(regLst) || ~isempty(lmkLst)
    fprintf('Updating region and landmark features ...\n')
    ftsLst.region = fea.getDistRegionBorderMIMO(evtx,dRecon,regLst,lmkLst);
else
    ftsLst.region = [];
end
setappdata(f,'fts',ftsLst);

% update events to show
waitbar(1,gg);
if ~isempty(regLst)
    btSt.regMask = sum(ftsLst.region.cell.memberIdx>0,2);
else
    btSt.regMask = ones(numel(ftsLst.loc.x3D),1);
end
setappdata(f,'btSt',btSt);
ui.updtEvtOvShowLst([],[],f);

% feature table
% show in event manager and for exporting
fts = getappdata(f,'fts');
tb = getappdata(f,'userFeatures');
nEvt = numel(fts.basic.area);
nFt = numel(tb.Name);
ftsTb = nan(nFt,nEvt);
ftsName = cell(nFt,1);
ftsCnt = 1;
dixx = fts.notes.propDirectionOrder;
for ii=1:nFt
    cmdSel0 = tb.Script{ii};
    ftsName0 = tb.Name{ii};
    % if find landmark or direction
    if ~isempty(strfind(cmdSel0,'xxLmk')) %#ok<STREMP>
        for xxLmk=1:numel(lmkLst)
            try
                eval([cmdSel0,';']);
            catch
                fprintf('Feature "%s" not used\n',ftsName0)
                x = nan(nEvt,1);
            end
            ftsTb(ftsCnt,:) = reshape(x,1,[]);
            ftsName1 = [ftsName0,' - landmark ',num2str(xxLmk)];
            ftsName{ftsCnt} = ftsName1;
            ftsCnt = ftsCnt + 1;
        end
    elseif ~isempty(strfind(cmdSel0,'xxDi')) %#ok<STREMP>
        for xxDi=1:4
            try
                eval([cmdSel0,';']);
            catch
                fprintf('Feature "%s" not used\n',ftsName0)
                x = nan(nEvt,1);
            end
            ftsTb(ftsCnt,:) = reshape(x,1,[]);
            ftsName1 = [ftsName0,' - ',dixx{xxDi}];
            ftsName{ftsCnt} = ftsName1;
            ftsCnt = ftsCnt + 1;
        end
    else
        try
            eval([cmdSel0,';']);
        catch
            fprintf('Feature "%s" not used\n',ftsName0)
            x = nan(nEvt,1);
        end
        ftsTb(ftsCnt,:) = reshape(x,1,[]);
        ftsName{ftsCnt} = ftsName0;
        ftsCnt = ftsCnt + 1;        
    end
end
featureTable = table(ftsTb,'RowNames',ftsName);
setappdata(f,'featureTable',featureTable);

fprintf('Done.\n')
delete(gg)

end







