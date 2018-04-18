%% detection results
p0 = 'D:\neuro_WORK\glia_kira\projects\tmp\';
f0 = 'FilteredNRMCCyto16m_slice2_TTX3_L2 3-012cycle1channel1.mat';
load([p0,f0]);

%% gather data from deteciton results
dat = double(res.dat)/256;
ov = res.ov;
ov0 = ov('Events');
[H,W,T] = size(dat);
evtMap = zeros(size(dat));
dRecon = zeros(size(dat));
for tt=1:T
    x0 = ov0.frame{tt};
    if ~isempty(x0)
        tmpOv = zeros(H,W);
        tmpEvt = zeros(H,W);
        for ii=1:numel(x0.idx)
            pix0 = x0.pix{ii};
            val0 = x0.val{ii};
            tmpOv(pix0) = val0;
            tmpEvt(pix0) = x0.idx(ii);
        end
        evtMap(:,:,tt) = tmpEvt;
        dRecon(:,:,tt) = tmpOv;
    end
end

% ov1 = plt.regionMapWithData(evtMap,dat,2,dRecon); zzshow(ov1);

% landmarks
evts = res.evt;
lmkAll = res.bd('landmk');
nLmk = numel(lmkAll);
lmkMsk = cell(nLmk,1);
for ii=1:nLmk
    lmkMsk{ii} = flipud(lmkAll{ii}{2});
end

%% all events
rr = burst.evt2lmkProp1Wrap(dRecon,evts,lmkMsk);

%% single event
nn = 19;
msk = zeros(size(dRecon));
msk(evts{nn}) = 1;
datS = dRecon.*msk;

res1 = burst.evt2lmkProp1(datS,lmkMsk);

% show event
tmp = zeros(H,W);
for ii=1:nLmk
    tmp = max(tmp,lmkMsk{ii}*0.25);    
end
dat3 = zeros(H,W,3,T);
dat3(:,:,2,:) = datS;
dat3(:,:,1,:) = repmat(tmp,1,1,T);
zzshow(dat3);













