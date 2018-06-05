function [bins,difTime] = mergeSeed(regMap,delayMap,initTimeSeedIn,cRiseMin,pertMax)
    
    pixLst = label2idx(regMap);
    nEvt = numel(initTimeSeedIn);
    [H,W] = size(regMap);
        
    % events distances
    [~,seedSortedIdx] = sort(initTimeSeedIn);
    difTime = inf(nEvt,nEvt);
    dh = [0 -1 1 0];
    dw = [-1 0 0 1];
    for nn=1:nEvt
        seed0 = seedSortedIdx(nn);
        pix0 = pixLst{seed0};
        [ih0,iw0] = ind2sub([H,W],pix0);
        t0 = initTimeSeedIn(seed0);
        for ii=1:numel(dh)
            ih0a = min(max(ih0+dh(ii),1),H);
            iw0a = min(max(iw0+dw(ii),1),W);
            pix0a = sub2ind([H,W],ih0a,iw0a);
            lbl0a = regMap(pix0a);
            lblSel = lbl0a~=seed0 & lbl0a>0;
            pix0Neib = pix0a(lblSel);
            pix0Bord = pix0(lblSel);
            for jj=1:numel(pix0Neib)
                n0 = regMap(pix0Neib(jj));
                %b0 = regMap(pix0Bord(jj));
                t1 = initTimeSeedIn(n0);
                tn0 = delayMap(pix0Neib(jj));
                tb0 = delayMap(pix0Bord(jj));
                tx = max(tn0,tb0);
                tmpx = min(tx-t0,tx-t1);
                if tmpx<5
                    %keyboard
                end
                difTime(seed0,n0) = min(difTime(seed0,n0),tmpx);
            end
        end
    end
    
    % merge events
    difTimePer = difTime - randi([0,pertMax],nEvt,nEvt);
    difTimeBi = difTimePer<cRiseMin;
    [s,t] = find(difTimeBi);
    G = graph(s,t,[],nEvt);
    bins = conncomp(G,'OutputForm','cell');
    
end