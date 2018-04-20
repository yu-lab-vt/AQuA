function [fts,evt,dffMat,riseLst,dMat,dRecon,lblMapC] = evtTop(dat,dF,lblMapS,riseMap,opts)
% evtTop super voxels to super events and optionally, to events

[H,W,T] = size(dat);

% get super events
opts0 = opts;
opts0.cDelay = max(opts.cDelay,10);  % 5 (ex vivo) or 10 (in vivo)
opts0.cDelay1 = 0;
lblMapC1 = burst.sp2evtStp1(lblMapS,riseMap,opts0.cDelay1,opts0.cDelay,opts0.cOver,dat);
c1x = label2idx(lblMapC1);

if opts.reSeg==1  % super event to event
    %opts1 = opts;
    %opts1.spSz = 10;
    %opts1.gtwSmo = opts1.reSegGtwSmo;  % !! larger for TTX, maybe smaller for in vivo    
    %[~,~,~,riseMap] = burst.alignPatchShort1(dat,datSmo,lblMapC1,dL>0,opts1);
    %[dRecon,riseMap,riseLst] = gtw.procMovie(dF,c1x,[],0,opts);
    %[~,riseMapx] = gtw.procMovie(dF,c1x,[],1,opts);
    lblMapC = burst.sp2evtStp2a(lblMapC1,lblMapS,riseMap,opts.cDelay,opts.cRise,1);
    % else  % use super event as event
    %     lblMapC = lblMapC;
    %lblMapC = burst.sp2evtStp2a(lblMapC1,lblMapS,riseMap,opts.cDelay,opts.cRise,1);
    %lblMapC = burst.sp2evtStp2b(dF,lblMapC1,lblMapS,riseMap,opts.cDelay,opts.cRise,1,opts.varEst);
else
    lblMapC = lblMapC1;
end

% merge and filter small events
lblMapC = burst.mergeEvt(lblMapC,opts);
lblMapC = burst.filterEvt(lblMapC,opts);
c2x = label2idx(lblMapC);

% refine events
fprintf('Refining events ...\n')
% [resLst,vLst,iLst,mskLst,dlyOrder] = burst.alignEvent(dat,datSmo,lblMapC,dL>0,opts);
% [lblMapC,dRecon] = burst.combineRes(lblMapC,dlyOrder,mskLst,resLst,vLst,iLst,H,W,T);
[dRecon,~,riseLst] = gtw.procMovie(dF,c2x,[],0,opts);

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



