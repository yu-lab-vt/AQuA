function [dat,dF,stdEst] = arSimPrep(dat,opts)
    
    mskSig = var(dat,0,3)>1e-8;
    dat = dat + randn(size(dat))*1e-6;

    if opts.smoXY>0
        for tt=1:size(dat,3)
            dat(:,:,tt) = imgaussfilt(dat(:,:,tt),opts.smoXY);
        end
    end
    
    % noise estimation
    xx = (dat(:,:,2:end)-dat(:,:,1:end-1)).^2;
    stdMap = sqrt(median(xx,3)/0.9133);
    stdMap(~mskSig) = nan;
    stdEst = double(nanmedian(stdMap(:)));
    
    dF = burst.getDfBlk(dat,mskSig,opts.cut,opts.movAvgWin,stdEst);
    
end




