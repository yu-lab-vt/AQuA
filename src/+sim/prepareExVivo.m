function p = prepareExVivo(datOrg,opts)
    % need to be tuned for each data
    
    datV = reshape(datOrg,[],opts.sz(3));
    xm = mean(datV,1);
    % figure;plot(xm);
    
    trgBg = xm<3.3e-3;
    dAvg = mean(datOrg(:,:,trgBg),3);
    
    xmMax = imregionalmax(imgaussfilt(xm,2));
    xmMax(xm<3.5e-3) = 0;
    pkLst = find(xmMax);
    nTmplt = numel(pkLst);
    dfBurstAvgLst = cell(nTmplt,1);
    dBurstStdLst = cell(nTmplt,1);
    for nn=1:nTmplt
        tx = pkLst(nn);
        trg = max(tx-10,1):min(tx+10,opts.sz(3));
        dBurst = datOrg(:,:,trg);
        dBurstStdLst{nn} = nanstd(dBurst,0,3);
        dBurstMin = nanmin(dBurst,3);
        dfBurstAvgLst{nn} = mean(dBurst-nanmean(dBurstMin(:)),3);
    end
    
    dStd = std(datOrg,0,3);
    sucRtAvg = imadjust(dStd.^2);
    % figure;imagesc(dStd);colorbar
    % figure;imagesc(sucRtAvg);colorbar
    fg = std(datOrg,0,3)>0.005;   
    
    % parameters
    p = [];        
    p.nSe = 20;
    p.numEvtInBurst = 4;
    p.nStart = 80;
    p.nStp = 200;
    p.nStpGrow = 200;
    p.dsRate = 20;
    p.cRise = 2;
    p.seedRtAdd = 0.5;
    p.seedRtMul = 1;
    p.seedMinDist = 30;
    p.seedDuraAdd = 0.5;
    p.speedUpProp = 0.01;
    p.pertMax = 0;
    p.tf = 120;
    p.tfUp = 20;
    p.tfDn = 100;
    p.temporalCross = 2;
    p.szRt = 1;
    
    p.cRiseMin = p.dsRate*p.cRise;
    p.sz = size(dAvg);
    p.dStd = dStd;
    p.nTmplt = nTmplt;
    p.sucRtAvg = sucRtAvg;
    p.fg = fg;
    p.dAvg = dAvg;
    p.dfBurstAvgLst = dfBurstAvgLst;
    p.dBurstStdLst = dBurstStdLst;
    p.opts = opts;
    
    p.tPerSe = p.nStp+p.tfUp+p.tfDn/p.temporalCross;
    
    % temporal filter
    gapUp = 1/(p.tfUp-1);
    fKerUp = 0:gapUp:1;
    fKerDn = exp(-(1:p.tfDn)/(p.tfDn/2));
    fKer = [fKerUp,fKerDn];
    fKer = fKer/sum(fKer);
    p.filter3D = reshape(fKer(end:-1:1),1,1,p.tf);

end




