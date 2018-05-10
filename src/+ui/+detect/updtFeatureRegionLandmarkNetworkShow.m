function updtFeatureRegionLandmarkNetworkShow(f,datR,evtLst,ftsLst,gg)

btSt = getappdata(f,'btSt');
bd = getappdata(f,'bd');
fm = btSt.filterMsk;
sz = size(datR);

% polygons
if bd.isKey('cell')
    bd0 = bd('cell');
    evtSpatialMask = zeros(sz(1),sz(2));
    regLst = cell(numel(bd0),1);
    for ii=1:numel(bd0)
        poly00 = bd0{ii}{1};
        regLst{ii} = poly00;
        spaMsk0 = poly2mask(poly00(:,1),poly00(:,2),sz(1),sz(2));
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

% use filtered events only
waitbar(0.6,gg);
evtx = evtLst;
if ~isempty(fm)
    for ii=1:numel(evtx)
        if fm(ii)==0
            evtx{ii} = [];
        end
    end
end

% landmark features
waitbar(0.7,gg);
if ~isempty(regLst) || ~isempty(lmkLst)
    fprintf('Updating region and landmark features ...\n')
    ftsLst.region = fea.getDistRegionBorderMIMO(evtx,datR,regLst,lmkLst);
else
    ftsLst.region = [];
end

% update events to show
waitbar(1,gg);
if ~isempty(regLst)
    btSt.regMask = sum(ftsLst.region.cell.memberIdx>0,2);
else
    btSt.regMask = ones(numel(ftsLst.loc.x3D),1);
end
setappdata(f,'btSt',btSt);
ui.over.updtEvtOvShowLst([],[],f);

% update network features
evtx1 = evtx;
if ~isempty(regLst)
    for ii=1:numel(evtx)
        if isfield(ftsLst,'loc2D')
            loc00 = ftsLst.loc2D{ii};
        else
            loc00 = ftsLst.loc.x2D{ii};
        end
        if sum(evtSpatialMask(loc00))==0
            evtx1{ii} = [];
        end
    end
end
ftsLst.networkAll = fea.getEvtNetworkFeatures(evtx,sz);  % all filtered events
ftsLst.network = fea.getEvtNetworkFeatures(evtx1,sz);  % events inside cells only
setappdata(f,'fts',ftsLst);

end


