function datSim = genSmall(p,mskIn,pltReg)
    % generate sparkling type evnets
    
    sgGau = imgaussfilt(p.dStd,1);
    sgRegMax = imregionalmax(sgGau);
    sgRegMax(p.fg==0) = 0;
    datAct = zeros(size(mskIn),'single');
    sucRtBase = p.sucRtAvg*2;
    
    T = size(mskIn);
    tVec = p.dsRate/2:p.dsRate/2:T;
    
    for nn=1:numel(tVec)
        fprintf('S.evt: %d\n',nn)
        
        t0 = tVec(nn);
        t1 = t0+p.tPerSe-1;
        mskCur = sum(mskIn(:,:,t0,t1),3);
        mskCur = imdilate(mskCur,strel('square',5));
                
        % choose seeds
        nEvt = randi(p.numEvtInBurst);
        sgRegMaxNow = sgRegMax;
        sgRegMaxNow(mskCur>0) = 0;
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
        sucRt = (rand(1,nEvt)*(1-p.seedRtAdd)+p.seedRtAdd)*p.seedRtMul;
        initTime = zeros(1,nEvt);
        duraTime = round((rand(1,nEvt)*p.seedDuraAdd+p.seedDuraAdd).*(p.nStp-initTime));
        
        % generate an event or a super event
        [datAct0,regMap0] = sim.genSe(seedIdx,sucRtBase,sucRt,initTime,duraTime,p);
        
        if pltReg
            figure;imagesc(regMap0,'AlphaData',regMap0>0);colorbar;  % partition
        end
        
        nSel = randi(p.nTmplt);
        dfBurstAvg = p.dfBurstAvgLst{nSel};
        mskIntensity = dfBurstAvg/max(dfBurstAvg(:));
        datAct0m = datAct0.*mskIntensity;
        
        t0x = t0+p.tfUp;
        t1x = t1-p.tfDn/p.temporalCross;
        datAct(:,:,t0x:t1x) = single(datAct0m);
        
        mskNew = sum(datAct0m,3) + datAct0m;
        mskIn(:,:,t0x:t1x) = mskIn(:,:,t0x:t1x) + mskNew>0;
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

