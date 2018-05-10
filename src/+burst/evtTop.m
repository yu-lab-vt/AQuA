function [riseLst,datR,datL,c1x] = evtTop(dat,dF,lblMapS,riseMap,opts,ff)
% evtTop super voxels to super events and optionally, to events

[H,W,T] = size(dat);

% super voxels to super events
fprintf('Detecting super events ...\n')
stp11 = max(round(opts.maxStp/2),2);
if opts.superEventdensityFirst==1
    [neibLst,exldLst] = burst.svNeib(lblMapS,riseMap,stp11,0.2);
    seMap = burst.sv2se(lblMapS,neibLst,exldLst);
else
    xx = double(riseMap); xx(xx==0) = nan;
    seMap = burst.sp2evtStp1(lblMapS,xx,0,stp11,0.2,dat);
end
c1x = label2idx(seMap);
if exist('ff','var')
    waitbar(0.2,ff);
end

% super event to events
fprintf('Detecting events ...\n')
riseLst = cell(0);
datR = zeros(H,W,T,'uint8');
datL = zeros(H,W,T);
nEvt = 0;
for nn=1:numel(c1x)
    se0 = c1x{nn};
    if isempty(se0)
        continue
    end
    fprintf('SE %d \n',nn)
    if exist('ff','var')
        waitbar(0.2+nn/numel(c1x)*0.55,ff);
    end
    
    [ih0,iw0,it0] = ind2sub([H,W,T],se0);    
    rgh = min(ih0):max(ih0); rgw = min(iw0):max(iw0);
    ihw0 = unique(sub2ind([numel(rgh),numel(rgw)],ih0-min(rgh)+1,iw0-min(rgw)+1));
    gapt = max(max(it0)-min(it0),5); rgt = max(min(it0)-gapt,1):min(max(it0)+gapt,T);
    
    dF0 = double(dF(rgh,rgw,rgt));
    seMap0 = seMap(rgh,rgw,rgt);    
    [evtRecon,evtL,evtMap,dlyMap,nEvt0,rgtx,rgtSel] = burst.se2evt(dF0,seMap0,nn,ihw0,rgh,rgw,rgt,it0,T,opts);  
    
    evtL(evtL>0) = evtL(evtL>0)+nEvt;
    dLNow = datL(rgh,rgw,rgtx);
    dRNow = datR(rgh,rgw,rgtx);
    ixOld = evtRecon<dRNow;
    evtL(ixOld) = dLNow(ixOld);
    datR(rgh,rgw,rgtx) = max(datR(rgh,rgw,rgtx),evtRecon);  % combine events
    datL(rgh,rgw,rgtx) = evtL;
    riseLst = burst.addToRisingMap(riseLst,evtMap,dlyMap,nEvt,nEvt0,rgh,rgw,rgt,rgtSel);
    nEvt = nEvt + nEvt0;
end

% ov1 = plt.regionMapWithData(spLst,zeros(H,W),0.3); zzshow(ov1);
% ov2 = plt.regionMapWithData(evtMap0,evtMap0*0,0.5); zzshow(ov2);

% merge and filter small events
datL = burst.mergeEvt(datL,opts.mergeEventDiscon);
if exist('ff','var')
    waitbar(0.8,ff);
end

end



