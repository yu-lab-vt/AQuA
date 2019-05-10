% re-calculate some features
% only update those proof-read

% choose path
% addpath(genpath('../../repo/aqua/'));
% px = getWorkPath('proj');
% p0 = [px,'/glia_kira/tmp/181109_detectionExamples/181113_s1_001_bl/'];
% f0 = '181113_s1_001_bl_AQuA';

addpath(genpath('./'))
[f0,p0] = uigetfile();
windowsize = 400; % the window for baseline estimation

%% read results and get overlay
fprintf('Loading...\n')
tmp = load([p0,f0]);
res = tmp.res;
opts = res.opts;
sz = opts.sz;
dat = double(res.datOrg);
dat = dat/max(dat(:));

evt = res.evt;
dff = res.dffMat(:,:,2);
evtMap = zeros(sz);
for ii=1:numel(evt)
    evtMap(evt{ii}) = ii;
end

ovx = res.ov('Events');
datR = zeros(sz);
for tt = 1:sz(3)
    ov0 = ovx.frame{tt};
    dRecon00 = zeros(sz(1), sz(2));
    if ~isempty(ov0)
        for ii = 1:numel(ov0.idx)
            dRecon00(ov0.pix{ii}) = ov0.val{ii};
        end
        datR(:, :, tt) = dRecon00;
    end
end

datR = datR.*(evtMap>0);


%% extend events and reconstructed signals
fprintf('Fixing...\n')
evtMapVec = reshape(evtMap,[],sz(3));
evtMapExt = zeros(size(evtMapVec));
datRVec = reshape(datR,[],sz(3));
datRExt = zeros(size(datRVec));

for ii=1:numel(evt)
    evt0 = evt{ii};
    c0 = dff(ii,:);
    std0 = sqrt(median((c0(2:end)-c0(1:end-1)).^2/2))/0.685;
    
    [ih0,iw0,it0] = ind2sub(sz,evt0);
    ihw0 = sub2ind(sz(1:2),ih0,iw0);
    ex0 = evtMapVec(ihw0,:);
    e0 = sum(ex0~=ii & ex0>0,1);
    
    xx = c0;
    base = xx;
    for k = 1:10
        base = movmean(min(xx, base), windowsize);
        cur = max(0, base - xx);
        sd = sqrt(sum(cur.^2) ./ (length(cur) - 1));
        if sd < std0
            break;
        end
    end
    c0 = c0 - base;
    std0 = sqrt(median((c0(2:end)-c0(1:end-1)).^2/2))/0.685;
    
    [xMax0,iMax0] = max(c0(it0));
    tMax0 = it0(iMax0);
    
    xThr0 = min(xMax0*opts.minShow1,std0);
    trg = min(it0):max(it0);
    
    % search backward
    t0 = min(it0);
    for tt=min(it0):-1:1
        if e0(tt)==0 && c0(tt)>=xThr0
            t0 = max(tt-1,1);
        elseif e0(tt)>0
            [~,dt] = min(c0(tt:min(it0)));
            t0 = tt+dt-1;
            break
        else
            break
        end
    end
    trg = union(t0:min(it0),trg);
    
    % search forward
    t0 = max(it0);
    for tt=max(it0):sz(3)
        if e0(tt)==0 && c0(tt)>=xThr0
            trg = union(trg,min(tt+1,res.opts.sz(3)));
        elseif e0(tt)>0
            [~,dt] = min(c0(max(it0):tt));
            t0 = max(it0)+dt-1;          
            break
        else
            break
        end
    end
    trg = union(max(it0):t0,trg);    
    evtMapExt(ihw0,trg) = ii;    
    evtMapVec = max(evtMapVec,evtMapExt);
    
    % re-map the reconstructed signals
    % maintain propagation in brighter signals
    r0 = datR(evt0);
    r0Min = min(r0);
    for tt=trg
        datRExt(ihw0,tt) = c0(tt)/xMax0;         
    end
    r1 = datRExt(evt0);
    r0MinNew = min(r1);
    r0ext = 1-(1-r0)*(1-r0MinNew)/(1-r0Min);
    datRExt(evt0) = r0ext;
end

evtMapExt = reshape(evtMapExt,sz);
datRExt = reshape(datRExt,sz);


%% update overlay
evtFilter = label2idx(evtMapExt);
nEvt = numel(evtFilter);
ovx = res.ov('Events');
for tt = 1:sz(3)
    ov0 = ovx.frame{tt};
    evtMap0 = evtMapExt(:,:,tt);
    rec0 = datRExt(:,:,tt);
    idx0 = label2idx(evtMap0);
    idx0 = idx0(~cellfun(@isempty,idx0));
    ov0.idx = [];
    ov0.pix = [];
    ov0.val = [];
    for ii = 1:numel(idx0)
        evt00 = idx0{ii};
        ov0.idx(ii) = evtMap0(evt00(1));        
        ov0.pix{ii} = evt00;
        ov0.val{ii} = rec0(evt00);
    end
    ovx.frame{tt} = ov0;
end
ovx.idx = 1:nEvt;
ovx.idxValid = ones(nEvt,1);
ovx.col = ovx.col(1:nEvt,:);
ovx.colVal = ovx.colVal(1:nEvt);
ovx.sel = true(nEvt,1);
res.ov('Events') = ovx;


%% update some features and save
fprintf('Preparing AQuA...\n')
[ftsLstE, dffMat, dMat] = fea.getFeaturesTop(dat, evtFilter, opts);
ftsLstE = fea.getFeaturesPropTop(dat, datRExt, evtFilter, ftsLstE, opts);

res.evt = evtFilter;
res.fts = ftsLstE;
res.dffMat = dffMat;
res.dMat = dMat;
res.riseLst = res.riseLstFilter;

res.evtFilter = res.evt;
res.ftsFilter = res.fts;
res.dffMatFilter = res.dffMat;
res.dMatFilter = res.dMat;

res.btSt.regMask = ones(nEvt,1);
res.btSt.filterMsk = ones(nEvt,1);
res.opts = opts;

aqua_gui(res)
% save([p0,f0,'_mod.mat'],'res');










