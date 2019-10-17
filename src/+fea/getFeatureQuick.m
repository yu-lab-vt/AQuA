function [ftsLst,dffMatExt] = getFeatureQuick(dat,evtLst,opts)
    % getPvalDffTop provide z score and p value based on dff curve
    % also provide original time window and extended time windows
    %
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
    
    % impute events
    fprintf('Imputing ...\n')
    datx = dat;
    datx(evtMap>0) = nan;
    datx = img.imputeMov(datx);
    
    Tww = min(opts.movAvgWin,T/4);
    
    % bias in moving average minimum
    xx = randn(1000,T);
    xxMovAvg = movmean(xx,Tww,2);
    bbm = mean(min(xxMovAvg,[],2));
    
    if ~isfield(opts,'correctTrend')
        opts.correctTrend = 0;
    end
    if ~isfield(opts,'bgFluo')
        opts.bgFluo = 0;
    end
    
    ftsLst = [];
    ftsLst.basic = [];
    ftsLst.propagation = [];
    ftsLst.curve.dffMaxZ = [];
    ftsLst.curve.dffMaxPval = [];
    ftsLst.curve.rgt1 = [];
    ftsLst.curve.tBegin = [];
    ftsLst.curve.tEnd = [];
    
    dffMatExt = nan(numel(evtLst),T);
    for ii=1:numel(evtLst)
        if mod(ii,100)==0
            fprintf('%d/%d\n',ii,numel(evtLst))
        end
        pix0 = evtLst{ii};
        if isempty(pix0)
            continue
        end
        [ih,iw,it] = ind2sub([H,W,T],pix0);
        rgH = max(min(ih)-1,1):min(max(ih)+1,H);
        rgW = max(min(iw)-1,1):min(max(iw)+1,W);
        rgT = max(min(it)-1,1):min(max(it)+1,T);
        
        if numel(rgT)==1
            keyboard
        end
        
        % dff
        voxd1 = dat(rgH,rgW,:);
        voxd1 = reshape(voxd1,[],T);
        voxi1 = evtMap(rgH,rgW,:);
        voxi1 = reshape(voxi1,[],T);
        
        sigxy = sum(voxi1==ii,2);
        sigz = sum(voxi1,1)>0;
        if sum(sigz)>T/2
            sigz = sum(voxi1==ii,1)>0;
        end
        
        charxIn1 = mean(voxd1(sigxy>0,:),1);
        charx1 = fea.curvePolyDeTrend(charxIn1,sigz,opts.correctTrend);
        sigma1 = sqrt(median((charx1(2:end)-charx1(1:end-1)).^2)/0.9113);
        
        charxBg1 = min(movmean(charx1,Tww));
        charxBg1 = charxBg1 - bbm*sigma1 - opts.bgFluo.^2;
        dff1 = (charx1-charxBg1)/charxBg1;
        sigma1dff = sqrt(median((dff1(2:end)-dff1(1:end-1)).^2)/0.9113);

        % dff without other events
        voxd2 = reshape(datx(rgH,rgW,:),[],T);
        idx = sub2ind([numel(rgH),numel(rgW),T],ih-min(rgH)+1,iw-min(rgW)+1,it);
        voxd2(idx) = voxd1(idx);  % bring current event back
        
        charxIn2 = nanmean(voxd2(sigxy>0,:),1);
        charx2 = fea.curvePolyDeTrend(charxIn2,sigz,opts.correctTrend);
        charxBg2 = min(movmean(charx2,Tww));
        charxBg2 = charxBg2 - bbm*sigma1 - opts.bgFluo.^2;
        dff2 = (charx2-charxBg2)/charxBg2;
        
        % for p values
        dff2Sel = dff2(rgT);
        [dffMax2,tMax] = max(dff2Sel);
        xMinPre = max(min(dff2Sel(1:tMax)),sigma1dff);
        xMinPost = max(min(dff2Sel(tMax:end)),sigma1dff);
        dffMaxZ = max((dffMax2-xMinPre+dffMax2-xMinPost)/sigma1dff/2,0);
        dffMaxPval = 1-normcdf(dffMaxZ);        
        
        % extend time window
        voxi1(voxi1==ii) = 0;
        sigxOthers = sum(voxi1>0,1)>0;
        [dff2Sel,rgT1] = fea.extendEventTimeRangeByCurve(dff2,sigxOthers,it);
        dffMatExt(ii,rgT1) = dff2Sel;
        
        % simple features
        ftsLst.curve.dffMaxZ(ii) = dffMaxZ;
        ftsLst.curve.dffMaxPval(ii) = dffMaxPval;
        ftsLst.curve.rgt1(ii,:) = [min(rgT1),max(rgT1)];
        ftsLst.curve.tBegin(ii) = min(it);
        ftsLst.curve.tEnd(ii) = max(it);
    end
    
end











