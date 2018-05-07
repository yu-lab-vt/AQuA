function [evtLst,ftsLst,dffMat,dMat] = getFeaturesTop(dat,evtMap,opts)
% getFeaturesTop extract curve related features, basic features and propagation
% dat: single (0 to 1)
% evtMap: single ( integer)

[H,W,T] = size(evtMap);

if opts.usePG
    dat = dat.^2;
end
secondPerFrame = opts.frameRate;
muPerPix = opts.spatialRes;

% impute events
fprintf('Imputing ...\n')
datx = dat; 
datx(evtMap>0) = nan;
datx = img.imputeMov(datx);

if ~isfield(opts,'maxValueDat')
    opts.maxValueDat = 1;
    opts.maxValueDepth = 256;
end
if ~isfield(opts,'correctTrend')
    opts.correctTrend = 1;
end

evtLst = label2idx(evtMap);
ftsLst = [];
ftsLst.basic = [];
ftsLst.propagation = [];

foptions = fitoptions('exp1');
foptions.MaxIter = 100;

dMat = zeros(numel(evtLst),T,2,'single');
dffMat = zeros(numel(evtLst),T,2,'single');
for ii=1:numel(evtLst)
    if mod(ii,10)==0
        fprintf('%d/%d\n',ii,numel(evtLst))
    end
    pix0 = evtLst{ii};
    if isempty(pix0)
        continue
    end
    [ih,iw,it] = ind2sub([H,W,T],pix0);
    ihw = unique(sub2ind([H,W],ih,iw));    
    rgH = max(min(ih)-1,1):min(max(ih)+1,H);
    rgW = max(min(iw)-1,1):min(max(iw)+1,W);
    rgT = min(it):max(it);
    
    % dff
    voxd1 = dat(rgH,rgW,:);
    voxd1 = reshape(voxd1,[],T);
    voxi1 = evtMap(rgH,rgW,:);
    voxi1 = reshape(voxi1,[],T);
    
    charxIn = mean(voxd1,1);
    sigx = sum(voxi1,1)>0;
    if sum(sigx)>T/2
        sigx = sum(voxi1==ii,1)>0;
    end
    charx1 = fea.curvePolyDeTrend(charxIn,sigx,opts.correctTrend);    
    %figure;plot(charxIn);hold on;plot(charx1);title(num2str(ii));keyboard;close    
    %charxBg = min(movmean(charx1,opts.movAvgWin));
    charxBg = min(movmean(charx1,T/2));
    dff1 = (charx1-charxBg)/charxBg; 
    s00 = sqrt(median((dff1(2:end)-dff1(1:end-1)).^2)/0.9113);
    
    % dff without other events
    voxd2 = reshape(datx(rgH,rgW,:),[],T);
    idx = sub2ind([numel(rgH),numel(rgW),T],ih-min(rgH)+1,iw-min(rgW)+1,it);
    voxd2(idx) = voxd1(idx);  % bring current event back
    %voxd1 = img.imputeMovVec(voxd1);
    
    charxIn = nanmean(voxd2,1);
    charx2 = fea.curvePolyDeTrend(charxIn,sigx,opts.correctTrend);    
    dff2 = (charx2-charxBg)/charxBg;    
    [dffMax,tMax] = max(dff2(rgT));
    dffMaxZ = dffMax/s00;
    dffMaxPval = 1-normcdf(dffMaxZ);
    %figure;plot(dff1);hold on;plot(dff2);
    
    % extend event window in the curve
    voxi1(voxi1==ii) = 0;
    sigxOthers = sum(voxi1>0,1)>0;
    [dff2e,rgT1] = fea.extendEventTimeRangeByCurve(dff2,sigxOthers,it);

    % curve features
    [ rise19,fall91,width55,width11,decayTau ] = fea.getCurveStat( ...
        dff2e, secondPerFrame, foptions, opts.ignoreTau );
    
    dffMat(ii,:,1) = single(dff1);
    dffMat(ii,:,2) = single(dff2);
    dMat(ii,:,1) = single(charx1*opts.maxValueDepth*opts.maxValueDat);
    dMat(ii,:,2) = single(charx2*opts.maxValueDepth*opts.maxValueDat);

    ftsLst.loc.t0(ii) = min(it);
    ftsLst.loc.t1(ii) = max(it);
    ftsLst.loc.x3D{ii} = pix0;
    ftsLst.loc.x2D{ii} = ihw;
    ftsLst.loc.rgt1(ii,:) = [min(rgT1),max(rgT1)];
    ftsLst.curve.dffMax(ii) = dffMax;
    ftsLst.curve.dffMaxFrame(ii) = (tMax+min(rgT)-1)*secondPerFrame;
    ftsLst.curve.dffMaxZ(ii) = dffMaxZ;
    ftsLst.curve.dffMaxPval(ii) = dffMaxPval;
    ftsLst.curve.tBegin(ii) = min(it);
    ftsLst.curve.tEnd(ii) = max(it);
    ftsLst.curve.rise19(ii) = rise19;
    ftsLst.curve.fall91(ii) = fall91;
    ftsLst.curve.width55(ii) = width55;
    ftsLst.curve.width11(ii) = width11;
    ftsLst.curve.decayTau(ii) = decayTau;
    
    % basic features
    ih1 = ih-min(rgH)+1;
    iw1 = iw-min(rgW)+1;
    it1 = it-min(rgT1)+1;
    voxd = dat(rgH,rgW,rgT1);
    voxi = zeros(size(voxd));
    pix1 = sub2ind(size(voxd),ih1,iw1,it1);
    voxi(pix1) = 1;
    ftsLst.basic = fea.getBasicFeatures(voxi,muPerPix,ii,ftsLst.basic);
end

ftsLst.bds = img.getEventBorder(evtLst,[H,W,T]);

end




