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

% landmarks
lmkMap1 = zeros(H,W);
lmkMap1(25:35,25:35) = 1;
lmkMap2 = zeros(H,W);
lmkMap2(1:5,1:5) = 1;
lmkMsk = {lmkMap1,lmkMap2};
% zzshow(lmkMap1+lmkMap2)

%% propagation related to landmark
evt00 = cell(1);
evt00{1} = find(datS>0);
rr = burst.evt2lmkProp1Wrap(datS,evt00,lmkMsk);




















