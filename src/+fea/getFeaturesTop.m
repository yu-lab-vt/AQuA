function [ftsLst,dffMat,dMat] = getFeaturesTop(dat,evtLst,opts)
% getFeaturesTop extract curve related features, basic features and propagation
% dat: single (0 to 1)
% evtMap: single ( integer)

[H,W,T] = size(dat);
evtMap = zeros(size(dat),'uint32');
for ii=1:numel(evtLst)
    evtMap(evtLst{ii}) = ii;
end

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

Tww = min(opts.movAvgWin,T/4);

% evtLst = label2idx(evtMap);
ftsLst = [];
ftsLst.basic = [];
ftsLst.propagation = [];

foptions = fitoptions('exp1');
foptions.MaxIter = 100;

dMat = zeros(numel(evtLst),T,2,'single');
dffMat = zeros(numel(evtLst),T,2,'single');
for ii=1:numel(evtLst)
    if mod(ii,100)==0
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
    rgT = max(min(it)-1,1):min(max(it)+1,T);
    %rgT = min(it):max(it);
    
    if numel(rgT)==1
%         keyboard
        continue
    end
    if ii==223
%         keyboard
    end       
    
    % dff
    voxd1 = dat(rgH,rgW,:);
    voxd1 = reshape(voxd1,[],T);
    voxi1 = evtMap(rgH,rgW,:);
    voxi1 = reshape(voxi1,[],T);
    
    charxIn1 = mean(voxd1,1);
    sigx = sum(voxi1,1)>0;
    if sum(sigx)>T/2
        sigx = sum(voxi1==ii,1)>0;
    end
    charx1 = fea.curvePolyDeTrend(charxIn1,sigx,opts.correctTrend);    
    %figure;plot(charxIn);hold on;plot(charx1);title(num2str(ii));keyboard;close    
    %charxBg = min(movmean(charx1,opts.movAvgWin));
    charxBg1 = max(min(movmean(charx1,Tww)),nanmin(charxIn1));
    dff1 = (charx1-charxBg1)/charxBg1; 
    %s00 = sqrt(median((dff1(2:end)-dff1(1:end-1)).^2)/0.9113);
    
    % dff without other events
    voxd2 = reshape(datx(rgH,rgW,:),[],T);
    idx = sub2ind([numel(rgH),numel(rgW),T],ih-min(rgH)+1,iw-min(rgW)+1,it);
    voxd2(idx) = voxd1(idx);  % bring current event back
    %voxd1 = img.imputeMovVec(voxd1);
    
    charxIn2 = nanmean(voxd2,1);
    charx2 = fea.curvePolyDeTrend(charxIn2,sigx,opts.correctTrend);
    charx2Na = charx2; charx2Na(sigx>0) = nan; charxBg2 = nanmedian(charx2Na);
    %charxBg2 = max(min(movmean(charx2,Tww)),nanmin(charxIn2));
    dff2 = (charx2-charxBg2)/charxBg2;    
    dff2a = (charx1-charxBg2)/charxBg2;
    s00 = sqrt(median((dff2a(2:end)-dff2a(1:end-1)).^2)/0.9113);
    
    dff2Sel = dff2(rgT);
    [dffMax,tMax] = max(dff2Sel);
    xMinPre = max(min(dff2Sel(1:tMax)),s00);
    xMinPost = max(min(dff2Sel(tMax:end)),s00);
    dffMaxZ = max((dffMax-xMinPre+dffMax-xMinPost)/s00/2,0);
    %dffMaxZ = mean(dffMax-xMinPre,dffMax-xMinPost)/s00;    
    %dffMaxZ = dffMax/s00;
    dffMaxPval = 1-normcdf(dffMaxZ);

    if 0
        figure;subplot(2,1,1);
        plot(charxIn1/max(charxIn1));hold on;plot(charx1/max(charx1));plot(dff1/max(dff1(:)));
        subplot(2,1,2);
        plot(charxIn2/max(charxIn2));hold on;plot(charx2/max(charx2));plot(dff2/max(dff2(:)));
        keyboard;close
    end
    
    % extend event window in the curve
    voxi1(voxi1==ii) = 0;
    sigxOthers = sum(voxi1>0,1)>0;
    [dff2e,rgT1] = fea.extendEventTimeRangeByCurve(dff2,sigxOthers,it);
    
    if 0
        fprintf('z: %f\n',dffMaxZ)
        figure;plot(dff2);hold on;plot(rgT1,dff2Sel,'r');
        keyboard;close
    end

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
    ftsLst.curve.rgt1(ii,:) = [min(rgT1),max(rgT1)];
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
    rgT = min(it):max(it);
    ih1 = ih-min(rgH)+1;
    iw1 = iw-min(rgW)+1;
    it1 = it-min(rgT)+1;
    voxd = dat(rgH,rgW,rgT);
    voxi = zeros(size(voxd));
    pix1 = sub2ind(size(voxd),ih1,iw1,it1);
    voxi(pix1) = 1;
    ftsLst.basic = fea.getBasicFeatures(voxi,muPerPix,ii,ftsLst.basic);
    
    % p values
    %[p0,z0] = fea.getPval(voxd,voxi,1,0,0,4,4,sqrt(opts.varEst));
    %ftsLst.basic.p0(ii) = p0;
    %ftsLst.basic.z0(ii) = z0;
end

ftsLst.bds = img.getEventBorder(evtLst,[H,W,T]);

end











