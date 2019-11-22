function dF = getDfBlk(datIn,evtSpatialMask,cut,movAvgWin,stdEst)
    
    if ~exist('stdEst','var') || isempty(stdEst)
        xx = (datIn(:,:,2:end)-datIn(:,:,1:end-1)).^2;
        stdMap = sqrt(median(xx,3)/0.9133);
        stdMap(evtSpatialMask==0) = nan;
        stdEst = double(nanmedian(stdMap(:)));
    end
    
    [H,W,T] = size(datIn);
    dF = zeros(H,W,T,'single');
    
    xx = randn(10000,cut)*stdEst;
    xxMA = movmean(xx,movAvgWin,2);
    xxMin = min(xxMA,[],2);
    xBias = nanmean(xxMin(:));


    nBlk = max(floor(T/cut),1);
    for ii=1:nBlk
        t0 = (ii-1)*cut+1;
        if ii==nBlk
            t1 = T;
        else
            t1 = t0+cut-1;
        end
        dat = datIn(:,:,t0:t1);
        
        datMA = movmean(dat,movAvgWin,3);
        datMin = min(datMA,[],3)-xBias;
        dF(:,:,t0:t1) = dat - datMin;
    end
    
end