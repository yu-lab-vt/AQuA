function res = detectionBatchPipeline(datOrg,opts,regLst,lmkLst)
    
    if ~exist('regLst','var')
        regLst = [];
    end
    if ~exist('lmkLst','var')
        lmkLst = [];
    end
    
    % detection
    [dat,dF,arLst,lmLoc,opts] = burst.actTop(datOrg,opts);  % foreground and seed detection
    [svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);  % super voxel detection
    
    [riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts);  % events
    [ftsLst,dffMat] = fea.getFeatureQuick(datOrg,evtLst,opts);
    
    % fitler by significance level
    mskx = ftsLst.curve.dffMaxZ>opts.zThr;
    dffMatFilterZ = dffMat(mskx,:);
    evtLstFilterZ = evtLst(mskx);
    tBeginFilterZ = ftsLst.curve.tBegin(mskx);
    riseLstFilterZ = riseLst(mskx);
    
    % merging (glutamate)
    evtLstMerge = burst.mergeEvt(evtLstFilterZ,dffMatFilterZ,tBeginFilterZ,opts);
    
    % reconstruction (glutamate)
    if opts.extendSV==0 || opts.ignoreMerge==0 || opts.extendEvtRe>0
        [riseLstE,datRE,evtLstE] = burst.evtTopEx(dat,dF,evtLstMerge,opts);
    else
        riseLstE = riseLstFilterZ; datRE = datR; evtLstE = evtLstFilterZ;
    end
    
    % feature extraction
    [ftsLstE,dffMatE,dMatE] = fea.getFeaturesTop(datOrg,evtLstE,opts);
    ftsLstE = fea.getFeaturesPropTop(dat,datRE,evtLstE,ftsLstE,opts);    
    
    muPix = opts.spatialRes;
    minSHow1 = opts.minShow1;    
    resReg = fea.getDistRegionBorderMIMO(evtLstE,datRE,regLst,lmkLst,muPix,minSHow1);
    ftsLstE.region = resReg;
    
    % output
    try
        res = fea.gatherRes(datOrg,opts,evtLstE,ftsLstE,dffMatE,dMatE,riseLstE,seLst,arLst,datRE);
    catch
        keyboard
    end
    
end

