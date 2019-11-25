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
    end
    if ~isfield(opts,'correctTrend')
        opts.correctTrend = 0;
    end
    if ~isfield(opts,'bgFluo')
        opts.bgFluo = 0;
    end
    
    Tww = min(opts.movAvgWin,T/4);
    
    % bias in moving average minimum
    %xx = randn(1000,T);
    %xxMovAvg = movmean(xx,Tww,2);
    %bbm = mean(min(xxMovAvg,[],2));
    bbm = 0;
    
    % bb = zeros(1,100);
    % for ii=1:100
    %     xx = randn(T,1);
    %     xxMovAvg = movmean(xx,Tww);
    %     bb(ii) = min(xxMovAvg);
    % end
    % bbm = mean(bb);
    
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
        
        if numel(rgT)==1
            continue
        end
        
        % dff
        
        voxi1 = evtMap(rgH,rgW,:);
        voxi1 = reshape(voxi1,[],T);               
        
        sigxy = sum(voxi1==ii,2);
        sigz = sum(voxi1,1)>0;
        if sum(sigz)>T/2
            sigz = sum(voxi1==ii,1)>0;
        end
        
        voxd1 = dat(rgH,rgW,:);
        voxd1 = reshape(voxd1,[],T);
        charxIn1 = mean(voxd1(sigxy>0,:),1);
        idx = sub2ind([numel(rgH),numel(rgW),T],ih-min(rgH)+1,iw-min(rgW)+1,it);
        evtData = voxd1(idx);
        clear voxd1;
        charx1 = fea.curvePolyDeTrend(charxIn1,sigz,opts.correctTrend);
        sigma1 = sqrt(median((charx1(2:end)-charx1(1:end-1)).^2)/0.9113);
        
        charxBg1 = min(movmean(charx1,Tww));
        charxBg1 = charxBg1 - bbm*sigma1 - opts.bgFluo^2;
        dff1 = (charx1-charxBg1)/charxBg1;
        sigma1dff = sqrt(median((dff1(2:end)-dff1(1:end-1)).^2)/0.9113);
        
        dff1Sel = dff1(rgT);
        dffMax1= max(dff1Sel);
        
        % dff without other events
        voxd2 = reshape(datx(rgH,rgW,:),[],T);
        voxd2(idx) = evtData;  % bring current event back
        charxIn2 = nanmean(voxd2(sigxy>0,:),1);
        clear voxd2;
        charx2 = fea.curvePolyDeTrend(charxIn2,sigz,opts.correctTrend);
        charxBg2 = min(movmean(charx2,Tww));
        charxBg2 = charxBg2 - bbm*sigma1 - opts.bgFluo^2;
        dff2 = (charx2-charxBg2)/charxBg2;
        
        if 1  % for p values
            dff2Sel = dff2(rgT);
            [dffMax2,tMax] = max(dff2Sel);
            xMinPre = max(min(dff2Sel(1:tMax)),sigma1dff);
            xMinPost = max(min(dff2Sel(tMax:end)),sigma1dff);
            dffMaxZ = max((dffMax2-xMinPre+dffMax2-xMinPost)/sigma1dff/2,0);
            dffMaxPval = 1-normcdf(dffMaxZ);
        end
        
        % extend event window in the curve
        voxi1(voxi1==ii) = 0;
        sigxOthers = sum(voxi1>0,1)>0;
        [dff2e,rgT1] = fea.extendEventTimeRangeByCurve(dff2,sigxOthers,it);
        
        % curve features
        [ rise19,fall91,width55,width11,decayTau,pp] = fea.getCurveStat( ...
            dff2e, secondPerFrame, foptions, opts.ignoreTau );
        
        dffMat(ii,:,1) = single(dff1);
        dffMat(ii,:,2) = single(dff2);
        dMat(ii,:,1) = single(charx1*opts.maxValueDat);
        dMat(ii,:,2) = single(charx2*opts.maxValueDat);
        
        ftsLst.loc.t0(ii) = min(it);
        ftsLst.loc.t1(ii) = max(it);
        ftsLst.loc.x3D{ii} = pix0;
        ftsLst.loc.x2D{ii} = ihw;
        ftsLst.curve.rgt1(ii,:) = [min(rgT1),max(rgT1)];
        ftsLst.curve.dffMax(ii) = dffMax1;
        ftsLst.curve.dffMax2(ii) = dffMax2;
        ftsLst.curve.dffMaxFrame(ii) = (tMax+min(rgT)-1);
        ftsLst.curve.dffMaxZ(ii) = dffMaxZ;
        ftsLst.curve.dffMaxPval(ii) = dffMaxPval;
        ftsLst.curve.tBegin(ii) = min(it);
        ftsLst.curve.tEnd(ii) = max(it);
        ftsLst.curve.duration(ii) = (max(it)-min(it)+1)*secondPerFrame;
        ftsLst.curve.rise19(ii) = rise19;
        ftsLst.curve.fall91(ii) = fall91;
        ftsLst.curve.width55(ii) = width55;
        ftsLst.curve.width11(ii) = width11;
        ftsLst.curve.dff1Begin(ii) = (pp(1,1)+min(rgT1)-1);
        ftsLst.curve.dff1End(ii) = (pp(1,2)+min(rgT1)-1);
        ftsLst.curve.width11(ii) = width11;
        ftsLst.curve.decayTau(ii) = decayTau;
        
        % basic features
        rgT = min(it):max(it);
        ih1 = ih-min(rgH)+1;
        iw1 = iw-min(rgW)+1;
        it1 = it-min(rgT)+1;
%         voxd = dat(rgH,rgW,rgT);
        voxi = zeros(length(rgH),length(rgW),length(rgT));
        pix1 = sub2ind(size(voxi),ih1,iw1,it1);
        voxi(pix1) = 1;
        ftsLst.basic = fea.getBasicFeatures(voxi,muPerPix,ii,ftsLst.basic);
        
        % p values
        %[p0,z0] = fea.getPval(voxd,voxi,1,0,0,4,4,sqrt(opts.varEst));
        %ftsLst.basic.p0(ii) = p0;
        %ftsLst.basic.z0(ii) = z0;
    end
    
    ftsLst.bds = img.getEventBorder(evtLst,[H,W,T]);
    
end











