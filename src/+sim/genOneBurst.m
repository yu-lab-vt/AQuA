function [datSim,datActDs,regMap1,delayMap1] = genOneBurst(datAvg,datBurst,p)
    
    [H,W] = size(datAvg);
    
    % activity map
    sg = std(datBurst,0,3); 
    sucRateBaseMap = imadjust(sg.^2);
    %sucRateBaseMap = ones(H,W);
    
    % local maximum and seeds
    sgGau = imgaussfilt(sg,1);
    sgRegMax = imregionalmax(sgGau);
    sgRegMax(p.fg==0) = 0;
    sgRegMax(sucRateBaseMap<=0.3) = 0;    
    locLm = find(sgRegMax);
    seedIdx = locLm(randperm(numel(locLm),p.nEvt));
    
    % distances between seeds
    msk = zeros(H,W);
    msk(seedIdx) = 1:p.nEvt;
    for ii=1:p.nEvt
        seed0 = seedIdx(ii);
        if msk(seed0)==0
            continue
        end
        [ih,iw] = ind2sub([H,W],seed0);
        rgh = max(ih-p.seedMinDist,1):min(ih+p.seedMinDist,H);
        rgw = max(iw-p.seedMinDist,1):min(iw+p.seedMinDist,W);
        msk(rgh,rgw) = 0; msk(seed0) = 1;
    end
    seedIdx = find(msk);
    nEvt = numel(seedIdx);
    
    % event properties
    sucRateSeed = (rand(1,p.nEvt)*(1-p.seedRtAdd)+p.seedRtAdd)*p.seedRtMul;
    initTimeSeed = randi(p.nStart,1,nEvt);

    % generate events by region growing
    [regMap,delayMap,pixLst] = sim.growSeed(seedIdx,initTimeSeed,...
        sucRateSeed,sucRateBaseMap,[],p);
    
    % merge non-detectable events and update seed information
    bins = sim.mergeSeed(regMap,delayMap,initTimeSeed,p.cRiseMin,p.pertMax);
    nEvt1 = numel(bins);
    seedIdx1 = zeros(nEvt1,1);
    initTimeSeed1 = zeros(nEvt1,1);
    sucRateSeed1 = zeros(nEvt1,1);
    regMap1 = zeros(H,W);
    for ii=1:nEvt1
        b0 = bins{ii};
        t0 = initTimeSeed(b0);
        [~,ix0] = min(t0);
        b0Sel = b0(ix0);
        seedIdx1(ii) = seedIdx(b0Sel);
        initTimeSeed1(ii) = min(initTimeSeed(b0));
        sucRateSeed1(ii) = sucRateSeed(b0Sel);
        for jj=1:numel(b0)
            regMap1(pixLst{b0(jj)}) = ii;
        end
    end
    
    [regMap1,delayMap1] = sim.growSeed(seedIdx1,initTimeSeed1,...
        sucRateSeed1,sucRateBaseMap,regMap1,p);
    %[bins1,difTime1] = sim.mergeSeed(regMap1,delayMap1,initTimeSeed1,cRiseMin-10);
    
    % generate data
    Tf = 100;
    Tsim = nanmax(delayMap1(:));
    datAct = zeros(H,W,Tsim);
    
    dfBurst = datBurst - datAvg;
    dfBurstAvg = mean(dfBurst,3);
    mskIntensity = dfBurstAvg;
    mskIntensity(mskIntensity<0) = 0;
    for tt=1:Tsim
        datAct(:,:,tt) = (delayMap1<=tt).*(mskIntensity.^2);
    end
    datAct = cat(3,zeros(H,W,Tf),datAct,zeros(H,W,Tf));
    
    datAct2 = imgaussfilt(datAct,0.5);
    f00 = reshape(ones(1,Tf)/Tf,1,1,Tf);
    datAct3 = imfilter(datAct2,f00);
    datActDs = datAct3(:,:,1:10:end);
    
    dsMax = max(datActDs,[],3);
    x0 = mean(dsMax(regMap1>0));
    x1 = mean(datAvg(regMap1>0));
    scl = x1/x0;
    datSim = datActDs*scl;
    
    if 0
        % burst locations
        datV = reshape(datOrg,[],T); %#ok<UNRCH>
        xm = mean(datV,1);
        figure;plot(xm);
        
        % seeds
        msk00 = zeros(H,W); msk00(seedIdx) = 1;
        tmp = cat(3,msk00,datAvg,sgRegMax>0); zzshow(tmp)
        
        % delay map
        [iy,ix] = ind2sub([H,W],seedIdx);
        figure;imagesc(delayMap,'AlphaData',~isnan(delayMap));colorbar;hold on;
        scatter(ix,iy,9,'r','filled');
        
        [iy,ix] = ind2sub([H,W],seedIdx1);
        figure;imagesc(delayMap1,'AlphaData',~isnan(delayMap1));colorbar;hold on;
        scatter(ix,iy,9,'r','filled');
        
        % partition
        RGB2 = label2rgb(regMap,'jet','w','shuffle'); zzshow(RGB2)
        RGB2 = label2rgb(regMap1,'jet','w','shuffle'); zzshow(RGB2)
        figure;imagesc(regMap,'AlphaData',regMap>0);colorbar;
        figure;imagesc(regMap1,'AlphaData',regMap1>0);colorbar;
        
        % movies
        datSimNy = datSim*0.5 + datAvg + randn(size(datSim))*0.05;
        zzshow(datSimNy*2)
    end
    
end








