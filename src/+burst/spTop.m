function [lblMapS,dReconSp,riseX,riseMap] = spTop(dat,dF,dL,datSmo,lmLoc,lmLocR,opts)

[H,W,T] = size(dat);
dReconSp = [];

% grow seeds
resCell = cell(numel(lmLoc),1);
lblMap = zeros(H,W,T,'uint32');
% fprintf('Init\n');
opts1 = opts;
opts1.maxStp = 1;
lmAll = zeros(H,W,T,'logical');
lmAll(lmLoc) = true;
[resCell,lblMap] = burst.growSeed(dat,datSmo,dF,resCell,lblMap,lmLoc,lmAll,dL,opts1,0);
for pp=1:40
    fprintf('Grow %d\n',pp);
    [resCell,lblMap] = burst.growSeed(dat,datSmo,dF,resCell,lblMap,lmLoc,lmAll,dL,opts1,pp);
end
lblMap = burst.gatherPatch(lblMap,lmAll,lmLocR,resCell);

% Extend and re-fit each patch, estimate delay, reconstruct signal
[lblMapS,riseMap,riseX] = burst.getSpDelay(dat,lblMap,dL,opts);
% [lblMapS,~,riseX,riseMap] = burst.alignPatchShort1(dat,datSmo,lblMap,dL,opts);

end