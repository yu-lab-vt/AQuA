function datSim = genBigEx(p,pltReg)
    % generate burst type evnets for ex vivo data
    
    sgGau = imgaussfilt(p.dStd,1);
    sgRegMax = imregionalmax(sgGau);
    sgRegMax(p.fg==0) = 0;

    datAct = zeros(p.sz(1),p.sz(2),p.tPerSe*p.nSe,'single');
    for nn=1:p.nSe
        fprintf('S.evt: %d\n',nn)
        
        %burstRt = rand()*0.8+0.2;
        burstRt = 1;
        
        % events template
        nSel = randi(p.nTmplt);
        sg = p.dBurstStdLst{nSel};
        sucRtBase0 = imadjust(sg);
        %sucRtBase1 = p.sucRtAvg;
        sucRtBase = sucRtBase0;
        %sucRtBase = (sucRtBase0+sucRtBase1)/2;
                
        % choose seeds
        nEvt = randi([round(p.numEvtInBurst/2),p.numEvtInBurst]);
        %nEvt = randi(p.numEvtInBurst);
        sgRegMaxNow = sgRegMax;
        sgRegMaxNow(sucRtBase<=0.3) = 0;
        locLm = find(sgRegMaxNow);
        seedIdx = locLm(randperm(numel(locLm),nEvt));
        
        % distances between seeds
        msk = zeros(p.sz);
        msk(seedIdx) = 1:nEvt;
        for ii=1:nEvt
            seed0 = seedIdx(ii);
            if msk(seed0)==0
                continue
            end
            [ih,iw] = ind2sub(p.sz,seed0);
            rgh = max(ih-p.seedMinDist,1):min(ih+p.seedMinDist,p.sz(1));
            rgw = max(iw-p.seedMinDist,1):min(iw+p.seedMinDist,p.sz(2));
            msk(rgh,rgw) = 0; msk(seed0) = 1;
        end
        seedIdx = find(msk);
        nEvt = numel(seedIdx);
        
        % event properties
        sucRt = (rand(1,nEvt)*(1-p.seedRtAdd)+p.seedRtAdd)*p.seedRtMul*burstRt;
        %sucRt = ones(1,nEvt);
        initTime = randi(p.nStart,1,nEvt);
        initTime = initTime - min(initTime);
        duraTime = round((rand(1,nEvt)*p.seedDuraAdd+p.seedDuraAdd).*(p.nStp-initTime));
        
        % generate an event or a super event
        % p.szRt = 0.5;
        [datAct0,regMap0,dlyMap0] = sim.genSe(seedIdx,sucRtBase,sucRt,initTime,duraTime,p);
        
        if pltReg
            f00 = figure;
            subplot(1,2,1);
            imagesc(dlyMap0,'AlphaData',~isnan(dlyMap0));colorbar;hold on;  % delay map
            [iy,ix] = ind2sub(p.sz,seedIdx); scatter(ix,iy,9,'r','filled');
            subplot(1,2,2);
            imagesc(regMap0,'AlphaData',regMap0>0);colorbar;  % partition
            f00.Position(3) = 1200;
            keyboard
            close
        end
        
        dfBurstAvg = p.dfBurstAvgLst{nSel};
        mskIntensity = dfBurstAvg/max(dfBurstAvg(:));
        datAct0m = datAct0.*mskIntensity;
        
        t0 = (nn-1)*p.tPerSe+1+p.tfUp;
        t1 = t0+size(datAct0m,3)-1;
        %t1 = nn*p.tPerSe-p.tfDn/p.temporalCross;
        datAct(:,:,t0:t1) = single(datAct0m);
    end
    
    % post processing
    datAct2 = zeros(size(datAct),'single');
    for tt=1:size(datAct,3)
        if mod(tt,1000)==0; fprintf('%d\n',tt); end
        datAct2(:,:,tt) = imgaussfilt(datAct(:,:,tt),0.5);
    end
    datAct2 = imfilter(datAct2,p.filter3D);
    datSim = datAct2(:,:,1:p.dsRate:end);    
    
end

