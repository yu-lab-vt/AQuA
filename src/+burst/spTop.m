function [lblMapS,dReconSp,riseX,riseMap] = spTop(dat,dF,lmLoc,opts)

thrSpSig = 4;

[H,W,T] = size(dat);
dReconSp = [];

% grow seeds
resCell = cell(numel(lmLoc),1);
lblMap = zeros(H,W,T,'uint32');
opts1 = opts;
opts1.maxStp = 1;
lmAll = zeros(H,W,T,'logical');
lmAll(lmLoc) = true;
[resCell,lblMap] = burst.growSeed(dat,dF,resCell,lblMap,lmLoc,lmAll,opts1,0);
for pp=1:40
    fprintf('Grow %d\n',pp);
    [resCell,lblMap] = burst.growSeed(dat,dF,resCell,lblMap,lmLoc,lmAll,opts1,pp);
end

% clean super voxels
lblMap = burst.filterAndFillSp(lblMap);
zVec1 = stat.getSpZ(dat,lblMap,opts.varEst);
spLst = label2idx(lblMap);
spLst = spLst(zVec1>thrSpSig);
lblMap = zeros(size(lblMap));
for nn=1:numel(spLst)
    lblMap(spLst{nn}) = nn;
end

% Extend and re-fit each patch, estimate delay, reconstruct signal
[lblMapS,riseMap,riseX] = burst.getSpDelay(dat,lblMap,opts);
% [lblMapS,~,riseX,riseMap] = burst.alignPatchShort1(dat,datSmo,lblMap,dL,opts);

% use significant super voxels only
% !! better to do this before extending?

% zVec1 = stat.getSpZ(dat,lblMapS,varEst);
% spLst = label2idx(lblMapS);
% spLst = spLst(zVec1>thrSpSig);
% lblMapS = zeros(size(lblMapS));
% for nn=1:numel(spLst)
%     lblMapS(spLst{nn}) = nn;
% end
% riseX = riseX(zVec1>thrSpSig,:);
% riseMap(lblMapS==0) = nan;

end