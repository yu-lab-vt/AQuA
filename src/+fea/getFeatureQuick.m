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

if ~isfield(opts,'correctTrend')
    opts.correctTrend = 1;
end

ftsLst = [];
ftsLst.basic = [];
ftsLst.propagation = [];

foptions = fitoptions('exp1');
foptions.MaxIter = 100;
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
    
    charxIn1 = mean(voxd1,1);
    sigx = sum(voxi1,1)>0;
    if sum(sigx)>T*0.8
        sigx = sum(voxi1==ii,1)>0;  % frames with other events
    end
    charx1 = fea.curvePolyDeTrend(charxIn1,sigx,opts.correctTrend);    
    
    % dff without other events
    voxd2 = reshape(datx(rgH,rgW,:),[],T);
    idx = sub2ind([numel(rgH),numel(rgW),T],ih-min(rgH)+1,iw-min(rgW)+1,it);
    voxd2(idx) = voxd1(idx);  % bring current event back
    
    charxIn2 = nanmean(voxd2,1);
    charx2 = fea.curvePolyDeTrend(charxIn2,sigx,opts.correctTrend);
    charx2Na = charx2; charx2Na(sigx>0) = nan; charxBg2 = nanmedian(charx2Na);
    dff2 = (charx2-charxBg2)/charxBg2;    
    dff2a = (charx1-charxBg2)/charxBg2;  % use raw df for noise
    s00 = sqrt(nanmedian((dff2a(2:end)-dff2a(1:end-1)).^2)/0.9113);
    
    % p value based on peak-base
    dff2Sel = dff2(rgT);
    [dffMax,tMax] = max(dff2Sel);
    xMinPre = min(dff2Sel(1:tMax));
    xMinPost = min(dff2Sel(tMax:end));
    if sum(sigx)<T*0.2
        xMinPre = max(xMinPre,s00);
        xMinPost = max(xMinPost,s00);
    end
    dffMaxZ = max(min(dffMax-xMinPre,dffMax-xMinPost)/s00/2,0);
    % dffMaxZ = max((dffMax-xMinPre+dffMax-xMinPost)/s00/2,0);
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











