function [evtLst,ftsLst,dffMat,dMat] = getFeaturesTop(dat,evtMap,evtRec,opts)

[H,W,T] = size(evtMap);

if opts.usePG
    dat = dat.^2;
end
secondPerFrame = opts.frameRate;
muPerPix = opts.spatialRes;

if ~isfield(opts,'maxValueDat')
    opts.maxValueDat = 1;
    opts.maxValueDepth = 256;
end

evtLst = label2idx(evtMap);
ftsLst = [];
ftsLst.basic = [];
ftsLst.propagation = [];

dMat = zeros(numel(evtLst),T,2,'single');
dffMat = zeros(numel(evtLst),T,2,'single');
foptions = fitoptions('exp1');
for ii=1:numel(evtLst)
    if mod(ii,100)==0
        fprintf('%d\n',ii)
    end
    pix0 = evtLst{ii};
    if isempty(pix0)
        continue
    end
    [ih,iw,it] = ind2sub([H,W,T],pix0);
    
    ihw = unique(sub2ind([H,W],ih,iw));
    ftsLst.loc.x3D{ii} = pix0;
    ftsLst.loc.x2D{ii} = ihw;
    
    rgH = max(min(ih)-1,1):min(max(ih)+1,H);
    rgW = max(min(iw)-1,1):min(max(iw)+1,W);
    rgT = min(it):max(it);
    
    % dff
    ftsLst.loc.t0(ii) = min(it);
    ftsLst.loc.t1(ii) = max(it);
    
    voxd1 = dat(rgH,rgW,:);
    voxd1 = reshape(voxd1,[],T);
    voxi1 = evtMap(rgH,rgW,:);
    voxi1 = reshape(voxi1,[],T);
    
    charx = mean(voxd1,1);
    dMat(ii,:,1) = single(charx*opts.maxValueDepth*opts.maxValueDat);
    
    charxBg = min(movmean(charx,opts.movAvgWin));
    dff = (charx-charxBg)/charxBg;
    dffMat(ii,:,1) = single(dff);
    
    % dff without other events
    voxd1(voxi1>0 & voxi1~=ii) = nan;
    charx1 = nanmean(voxd1,1);
    dMat(ii,:,2) = single(charx1*opts.maxValueDepth*opts.maxValueDat);
    
    dff = (charx1-charxBg)/charxBg;
    dffMat(ii,:,2) = single(dff);    
    [dffMax,tMax] = max(dff(rgT));
    ftsLst.curve.dffMax(ii) = dffMax;
    ftsLst.curve.dffMaxFrame(ii) = (tMax+min(rgT)-1)*secondPerFrame;
        
    % extend event window in the curve    
    voxi1(voxi1==ii) = 0;
    evt1 = sum(voxi1>0,1);
    
    t0 = max(min(it)-1,1);
    t1 = min(max(it)+1,T);
    if min(it)>1
        i0 = find(evt1(1:t0)>0,1,'last');
    else
        i0 = [];
    end
    if max(it)<T
        i1 = find(evt1(t1:T)>0,1);
        i1 = i1+t1-1;
    else
        i1 = [];
    end
    
    if ~isempty(i0)
        [~,ix] = min(dff(i0:min(it)));
        t0a = i0+ix-1;
    else
        t0a = min(it);
    end
    if ~isempty(i1)
        [~,ix] = min(dff(max(it):i1));
        t1a = max(it)+ix-1;
    else
        t1a = max(it);
    end
    if t0a>=t1a
        t0a = t0;
        t1a = t1;
    end
    dff1 = dff(t0a:t1a);
    ftsLst.curve.tBegin(ii) = min(it);
    ftsLst.curve.tEnd(ii) = max(it);
    
    % curve features
    [ rise19,fall91,width55,width11,decayTau ] = fea.getCurveStat( ...
        dff1, secondPerFrame, foptions, opts.ignoreTau );
    ftsLst.curve.rise19(ii) = rise19;
    ftsLst.curve.fall91(ii) = fall91;
    ftsLst.curve.width55(ii) = width55;
    ftsLst.curve.width11(ii) = width11;
    ftsLst.curve.decayTau(ii) = decayTau;
    
    % basic features
    rgT = t0:t1;
    ih1 = ih-min(rgH)+1;
    iw1 = iw-min(rgW)+1;
    it1 = it-min(rgT)+1;
    
    voxd = dat(rgH,rgW,rgT);
    voxi = zeros(size(voxd));
    pix1 = sub2ind(size(voxd),ih1,iw1,it1);
    voxi(pix1) = 1;
    voxr = evtRec(rgH,rgW,rgT);
    voxr = double(voxr)/255;
    
    % basic features
    if ii==228
%         keyboard
    end
    [ftsLst.basic,ftsLst.propagation] = fea.getFeatures1(voxi,voxr,muPerPix,ii,ftsLst.basic,ftsLst.propagation);
    %fts = burst.getFeatures(voxd,voxi,voxr,muPerPix,fts,ii);
end

ftsLst.bds = img.getEventBorder(evtLst,[H,W,T]);
ftsLst.notes.propDirectionOrder = {'north', 'south', 'west', 'east'};

end









