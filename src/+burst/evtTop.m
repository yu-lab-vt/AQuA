function [fts,evt,dffMat,dMat,dRecon,resLst,riseMap,lblMapC] = evtTop(...
    dat,datSmo,dF,dL,lblMapS,riseMap,opts)

[H,W,T] = size(dat);

% get events
% riseMap1 = riseMap;
opts0 = opts;
opts0.cDelay = max(opts.cDelay,10);  % 5 (ex vivo) or 10 (in vivo)
% if opts0.cDelay1==0
opts0.cDelay1 = 0;
% opts0.cDelay1 = opts0.cDelay;
% end
lblMapC1 = burst.sp2evtStp1(lblMapS,riseMap,opts0.cDelay1,opts0.cDelay,opts0.cOver,dat);
c1x = label2idx(lblMapC1);

%if 0
if opts.reSeg==1  % re-estimate phase
    opts1 = opts;
    opts1.spSz = 10;
    opts1.gtwSmo = opts1.reSegGtwSmo;  % !! larger for TTX, maybe smaller for in vivo
    [~,~,~,riseMap] = burst.alignPatchShort1(dat,datSmo,lblMapC1,dL>0,opts1);
    lblMapC = burst.sp2evtStp2a(lblMapC1,lblMapS,riseMap,opts.cDelay,opts.cRise,0);
else
    lblMapC = burst.sp2evtStp2a(lblMapC1,lblMapS,riseMap,opts.cDelay,opts.cRise,1);
    %lblMapC = burst.sp2evtStp2b(dF,lblMapC1,lblMapS,riseMap,opts.cDelay,opts.cRise,1,opts.varEst);
end

% merge and filter small events
lblMapC = burst.mergeEvt(lblMapC,opts);
lblMapC = burst.filterEvt(lblMapC,opts);
c2x = label2idx(lblMapC);

% refine events
fprintf('Refining events ...\n')
[resLst,vLst,iLst,mskLst,dlyOrder] = burst.alignEvent(dat,datSmo,lblMapC,dL>0,opts);
[lblMapC,dRecon] = burst.combineRes(lblMapC,dlyOrder,mskLst,resLst,vLst,iLst,H,W,T);

% features
fprintf('Extrating features ...\n')
try
    [evt,fts,dffMat,dMat] = burst.getFeaturesTop(dat,lblMapC,dRecon,opts);
    fts.network = burst.getEvtNetworkFeatures(evt,[H,W,T]);
catch
    fprintf('Feature extraction error\n')
    keyboard
end

end



