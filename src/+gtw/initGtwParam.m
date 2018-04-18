function param = initGtwParam( validMap,tstVarMap,bds,bdsCell,opts )
%INITGTWPARAM set parameters for GTW
% !! use off-diagonal cost or not?
% !! how large is smoothness?

param = [];
param.smoBase = opts.gtwSmo;  % baseline smoothness, 1
param.smox = 1;

tmpEast = validMap*1;
tmpSouth = validMap*1;
param.smoMap = cat(3,tmpEast,tmpSouth)*param.smoBase;  % smoothness, east and south for each pixel

param.s2 = tstVarMap;  % noise variance map
param.epAdd = opts.gtwAdd;
param.epMul = opts.gtwMul;
param.winSize = max(opts.maxStp,1);  % 5 or 10
param.offDiagonalPenalty = opts.gtwOffDiagonal;  % 0,1,2
param.inf0 = 1e12;
param.partialMatchingCost = (0:param.winSize)*opts.gtwPartialMatchingCoef;  % 0.5 or 1e8

param.bds = bds;
param.bdsCell = bdsCell;

end

