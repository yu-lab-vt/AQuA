function res = fitOnCr1(dat,opts,validMap)
%fitOnCr fit a region
%
% !!!! Use delta F as input data
%
% The following is needed in 'opts':
%   Useful: varEst, gtwSmo, maxStp, pixThr, regThr, minSize
%   Others: rescaleTst, gtwAdd, gtwMul, gtwOffDiagonal, gtwPartialMatchingCoef

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
pathCell = cell(H,W);
param = gtw.initGtwParam( validMap,tstVarMap,zeros(H,W),cell(H,W),opts );

% tic; 
[path0,~] = gtw.getGtwPath( ref, tst, validMap, param ); 
% toc

pathCell(validMap>0) = path0;
datWarp2Ref = gtw.warpTst2Ref(pathCell,dat,validMap,0);
datWarp = gtw.warpRef2Tst(pathCell,refBase,validMap,[H,W,T]);

% linear regression for each pixel
yDeMean = dat - mean(dat,3);
xDeMean = datWarp - mean(datWarp,3);

kMap = mean(yDeMean.*xDeMean,3)./mean(xDeMean.^2,3);
rho0Map = kMap./sqrt(mean(yDeMean.^2,3)).*sqrt(mean(xDeMean.^2,3));
z0Map = stat.getFisherTrans(rho0Map,T);

datRec = datWarp.*kMap;

% delay map on rising edge
[~,ix2] = max(refBase);
ix1 = find(refBase>opts.varEst/2,1);  % !!!
if isempty(ix1)
    ix1 = 1;
end
tVec = ix1:ix2;  % !! determine according to ref curve
t00 = mean(tVec);
[dMap,dMapS] = burst.getDelayMap(pathCell,tVec,H,W);

% output
res = [];
res.pathCell = pathCell;
res.validMap = validMap;
res.ref = refBase;
res.datWarp2Ref = datWarp2Ref;
res.datWarp = datWarp;
res.datRec = datRec;
res.kMap = kMap;
res.rho0Map = rho0Map;
res.z0Map = z0Map;
% res.z1Map = z1Map;
res.dMap = dMap;
res.dMapS = dMapS;
res.tEvtUp = t00;
res.H = H;
res.W = W;
res.T = T;

end




