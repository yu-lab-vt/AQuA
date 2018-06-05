function [dAct,regM1,dlyM1] = genSe(sIdx,sucRtBase,sucRt,initTime,duraTime,p)    

    % generate events region and delay maps by region growing
    [regMap,delayMap,pixLst] = sim.growSeed(sIdx,initTime,sucRt,sucRtBase,[],p);
    
    % merge non-detectable events and update seed information
    bins = sim.mergeSeed(regMap,delayMap,initTime,p.cRiseMin,p.pertMax);
    nEvt1 = numel(bins);
    sIdx1 = zeros(nEvt1,1);
    initTime1 = zeros(nEvt1,1);
    duraTime1 = zeros(nEvt1,1);
    sucRt1 = zeros(nEvt1,1);
    regM1 = zeros(p.sz);
    for ii=1:nEvt1
        b0 = bins{ii};
        t0 = initTime(b0);
        [~,ix0] = min(t0);
        b0Sel = b0(ix0);
        sIdx1(ii) = sIdx(b0Sel);
        initTime1(ii) = min(initTime(b0));
        duraTime1(ii) = max(duraTime(b0));
        sucRt1(ii) = sucRt(b0Sel);
        for jj=1:numel(b0)
            regM1(pixLst{b0(jj)}) = ii;
        end
    end
    
    % update region and delay map
    [regM1,dlyM1,pixLst1] = sim.growSeed(sIdx1,initTime1,sucRt1,sucRtBase,regM1,p);
    
    % generate data
    Tsim = nanmax(dlyM1(:));
    dAct = zeros(p.sz(1),p.sz(2),Tsim);
    for tt=1:Tsim
        dAct(:,:,tt) = 1*(dlyM1<=tt);
    end
    
    % duration limits
    dAct = reshape(dAct,[],Tsim);
    for nn=1:numel(pixLst1)
        td0 = duraTime1(nn);
        pix0 = pixLst1{nn};
        for ii=1:numel(pix0)
            x = dAct(pix0(ii),:);
            t0 = find(x,1);
            x(t0+td0-1:end) = 0;
            dAct(pix0(ii),:) = x;
        end     
    end
    dAct = reshape(dAct,[p.sz,Tsim]);
    
end








