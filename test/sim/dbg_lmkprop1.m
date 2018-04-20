%% simulation with complex events
H = 60;
W = 60;
T = 50;
datS = zeros(H,W,T);
for tt=5:45
    tmp = zeros(H,W);
    yrg = tt:tt+10;
    xrg = 25:35;
    tmp(yrg,xrg) = 1;
    yrg = 25:35;
    xrg = tt:tt+10;
    tmp(yrg,xrg) = 1;
    datS(:,:,tt) = tmp;
end
% zzshow(datS);

evt00 = cell(1);
evt00{1} = find(datS>0);

%% landmark 1
lmkMap1 = zeros(H,W);
lmkMap1(25:35,25:35) = 1;
lmkMap2 = zeros(H,W);
lmkMap2(1:5,1:5) = 1;
lmkMsk = {lmkMap1,lmkMap2};
% zzshow(lmkMap1+lmkMap2)
rr1 = fts.evt2lmkProp1Wrap(datS,evt00,lmkMsk);

%% landmark 2
nDir = 4;
[H0,W0,~] = size(datS);
lmkMsk4 = cell(nDir,1);
for ii=1:nDir
    tmp = zeros(H0,W0);
    % south, north, west, east
    switch ii
        case 1
            tmp(end,:) = 1;
        case 2
            tmp(1,:) = 1;
        case 3
            tmp(:,1) = 1;
        case 4
            tmp(:,end) = 1;
    end
    lmkMsk4{ii} = tmp;
end

res1 = fts.evt2lmkProp1(datS,lmkMsk4);

pixTwd = res1.pixelToward;
pixTwdNorm = pixTwd./sum(pixTwd,3);
% x11 = pixTwdNorm(:,:,1);
x11 = pixTwd(:,:,4);
figure;imagesc(x11);colorbar

rr2 = fts.evt2lmkProp1Wrap(datS,evt00,lmkMsk4);

pixTwd = rr2.pixelToward{1};
x11 = pixTwd(:,:,1);
figure;imagesc(x11);colorbar










