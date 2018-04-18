f = 'D:\neuro_WORK\glia_kira\tmp\debug\fitting_warning.mat';
load(f);

dat = d0;
validMap = v0;

[H,W,T] = size(dat);

opts.maxStp = max(min(opts.maxStp,T-2),1);

datSmo = img.smoothMovie(dat,1,1,0,1);
datScl = max(datSmo,[],3);

% correlation map for seeds
pixStrength = nanstd(dat,0,3);
pixStrength(validMap<1) = -2;

% prepare for fitting
seedInfo = burst.initSeed( validMap,pixStrength,opts.blkGapSeed );

% scale by magnifitude
[ref,tst,refBase,tstVarMap] = burst.initCurve1( dat,validMap,seedInfo,datScl,opts.varEst );

% GTW fitting and warping
param = gtw.initGtwParam( validMap,tstVarMap,zeros(H,W),cell(H,W),opts );
[ ss,ee,gInfo ] = gtw.buildGraph4Aosokin( ref, tst, validMap, param);

%%
[~, labels] = aoIBFS.graphCutMex(ss,ee);


%%
v0 = var(tst,[],2);
v1 = var(ref,[],2);




