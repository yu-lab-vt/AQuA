function [dat,dF,arLst,lmLoc,opts,dActVox] = actTop(dat,opts,evtSpatialMask,ff)
    
    % valid region
    if ~isfield(opts,'fgFluo')
        opts.fgFluo = 0;
    end
    [H,W,T] = size(dat);
    datOrgMean = mean(dat,3);
    msk000 = var(dat,0,3)>1e-8;
    if exist('evtSpatialMask','var') && ~isempty(evtSpatialMask)
        evtSpatialMask = evtSpatialMask.*msk000;
    else
        evtSpatialMask = msk000;
    end
    noiseEstMask = evtSpatialMask.*(datOrgMean>opts.fgFluo);
    
    % For save memory
    if ~isfield(opts,'legacyModeActRun') || opts.legacyModeActRun==0
        datOrg = dat;
    end
    
    % noise for raw data
    for x = 1:H
        for y = 1:W
            xx = (dat(x,y,2:end)-dat(x,y,1:end-1)).^2;
            stdMap(x,y) = sqrt(median(xx,3)/0.9133);
        end
    end
%     stdMap = sqrt(median(xx,3)/0.9133);
    stdMapGauBef = double(imgaussfilt(stdMap));
    stdMapGauBef(noiseEstMask==0) = nan;
    stdEstBef = double(nanmedian(stdMapGauBef(:))) + 1e-6;
    
    % smooth the data
    dat = dat;
    if opts.smoXY>0
        for tt=1:size(dat,3)
            dat(:,:,tt) = imgaussfilt(dat(:,:,tt),opts.smoXY);
        end
    end
    
    % noise for smoothed data
    for x = 1:H
        for y = 1:W
            xx = (dat(x,y,2:end)-dat(x,y,1:end-1)).^2;
            stdMap(x,y) = sqrt(median(xx,3)/0.9133);
        end
    end
    stdMapGau = double(imgaussfilt(stdMap));
    stdMapGau(noiseEstMask==0) = nan;
    stdEst = double(nanmedian(stdMapGau(:))) + 1e-6;
    
    % delta F
    dF = burst.getDfBlk(dat,noiseEstMask,opts.cut,opts.movAvgWin,stdEst);
%     idx00 = find(dF<=0);
%     dF(idx00) = randn(numel(idx00),1)*stdEst;
    if exist('ff','var')
        waitbar(0.5,ff);
    end
    
    % noise and threshold, get active voxels
    if isfield(opts,'legacyModeActRun') && opts.legacyModeActRun>0
        opts.varEst = stdEstBef.^2;
%         opts.varMap = stdMapGauBef.^2;
        [arLst,dActVox] = burst.getAr(dF,opts,evtSpatialMask);
    else
        opts.varEst = stdEst.^2;
%         opts.varMap = stdMapGau.^2;
        %[arLst,dActVox] = burst.getARSimZ(datOrg,opts,evtSpatialMask,opts.smoXY,opts.thrARScl);
        %[arLst,dActVox] = burst.getAr(dF,opts,evtSpatialMask);
        [arLst,dActVox] = burst.getARSim(datOrg,opts,evtSpatialMask,opts.smoXY,opts.thrARScl,opts.minSize);
    end
    
    if exist('ff','var')
        waitbar(0.8,ff);
    end
    
    % seeds
    fsz = [1 1 0.5];  % smoothing for seed detection
    lmLoc = burst.getLmAll(dat,arLst,dActVox,fsz);
    if exist('ff','var')
        waitbar(1,ff);
    end
    
end

