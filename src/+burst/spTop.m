function [svLst,dReconSp,riseX] = spTop(dat,dF,lmLoc,evtSpatialMask,opts,ff)
    
    [H,W,T] = size(dat);
    dReconSp = [];
    
    if isempty(evtSpatialMask)
        evtSpatialMask = ones(H,W);
    end
    if ~isfield(opts,'thrSvSig')
        opts.thrSvSig = 4;
    end
    
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
        if exist('ff','var')
            waitbar(0.1+pp/80,ff);
        end
        [resCell,lblMap] = burst.growSeed(dat,dF,resCell,lblMap,lmLoc,lmAll,opts1,pp);
    end
    
    % clean super voxels
    fprintf('Cleaning super voxels by size ...\n')
    lblMap = lblMap.*uint32(evtSpatialMask);
    lblMap = burst.filterAndFillSp(lblMap);
    
    if exist('ff','var')
        waitbar(0.7,ff);
    end
    
    fprintf('Cleaning super voxels by z score...\n')
    zVec1 = stat.getSpZ(dat,lblMap,opts.varEst);
    spLst = label2idx(lblMap);
    spLst = spLst(zVec1>opts.thrSvSig);
    lblMap = zeros(size(lblMap));
    for nn=1:numel(spLst)
        lblMap(spLst{nn}) = nn;
    end
    
    if exist('ff','var')
        waitbar(0.8,ff);
    end
    
    % Extend and re-fit each patch, estimate delay, reconstruct signal
    fprintf('Extending super voxels ...\n')
    [lblMap,riseX] = burst.getSpDelay(dat,lblMap,opts);
    
    if exist('ff','var')
        waitbar(1,ff);
    end
    
    % poolobj = gcp('nocreate');
    % delete(poolobj);
    
    svLst = label2idx(lblMap);
    
end

