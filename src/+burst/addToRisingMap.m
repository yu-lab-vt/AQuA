function riseLst = addToRisingMap(riseLst,evtMap,dlyMap,nEvt,nEvt0,rgh,rgw,rgt,rgtSel)
% split the rising time map to different events
for ii=1:nEvt0
    [ihr,iwr] = find(evtMap==ii);
    if ~isempty(ihr)
        rghr = min(ihr):max(ihr);
        rgwr = min(iwr):max(iwr);
        evtMapr = evtMap(rghr,rgwr);
        dlyMapr = (dlyMap(rghr,rgwr)+rgt(1)+rgtSel(1)-1-1).*(evtMapr==ii);
        dlyMapr(dlyMapr==0) = nan;
        rr = [];
        rr.dlyMap = dlyMapr;
        rr.rgh = min(rgh)+rghr-1;
        rr.rgw = min(rgw)+rgwr-1;
        riseLst{nEvt+ii} = rr;
    end
end
end