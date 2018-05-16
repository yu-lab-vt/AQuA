function [arLst,dARAll] = getARSimZ(dat,opts,evtSpatialMask,smoMax,thrMin)
    % still have problems
    % FIXME: ratio of time points in simulaiton and real data
    
    % learn noise correlation
    T1 = min(size(dat,3),100);
    datZ = zscore(dat(:,:,1:T1),0,3);
    rhox = mean(datZ(:,1:end-1,:).*datZ(:,2:end,:),3);
    rhoy = mean(datZ(1:end-1,:,:).*datZ(2:end,:,:),3);
    rhoxM = nanmedian(rhox(:));
    rhoyM = nanmedian(rhoy(:));
    
    rr = load('./cfg/smoCorr.mat');
    [~,ix] = min(abs(rhoxM-rr.cx));
    [~,iy] = min(abs(rhoyM-rr.cy));
    smo0 = rr.sVec(max(ix,iy));
    
    dSim = randn(opts.sz(1),opts.sz(2),200)*0.2;
    dSim = imgaussfilt(dSim,[smo0 smo0]);
    
    % simulation
    smoVec = smoMax;
    thrVec = thrMin+3:-1:thrMin;
    
    dARAll = zeros(opts.sz);
    for ii=1:numel(smoVec)
        fprintf('Smo %d ==== \n',ii);
        opts.smoXY = smoVec(ii);
        
        [~,dFSim,sSim] = burst.arSimPrep(dSim,opts);
        [~,dFReal,sReal] = burst.arSimPrep(dat,opts);
        for jj=1:numel(thrVec)
            dAR = zeros(opts.sz);
            fprintf('Thr %d \n',jj);
            
            zRg = 0:0.1:100;
            
            % null
            zSim = dFSim/sSim;
            tmpSim = zSim>thrVec(jj);
            zNull = zRg*0;
            for tt=1:size(dSim,3)
                z00 = zSim(:,:,tt);
                tmp00 = tmpSim(:,:,tt).*evtSpatialMask;
                cc = bwconncomp(tmp00);
                ccSz = cellfun(@numel,cc.PixelIdxList);
                for mm=1:numel(ccSz)
                    pix00 = cc.PixelIdxList{mm};
                    z00x = mean(z00(pix00))*sqrt(numel(pix00));
                    z00x = max(min(z00x,100),0);
                    idx00x = round(z00x*10)+1;
                    zNull(idx00x) = zNull(idx00x)+1;
                end
            end
            
            % observation
            zReal = dFReal/sReal;
            tmpReal = zReal>thrVec(jj);
            zObs = zRg*0;
            for tt=1:size(dat,3)
                z00 = zReal(:,:,tt);
                tmp00 = tmpReal(:,:,tt).*evtSpatialMask;
                cc = bwconncomp(tmp00);
                ccSz = cellfun(@numel,cc.PixelIdxList);
                for mm=1:numel(ccSz)
                    pix00 = cc.PixelIdxList{mm};
                    z00x = mean(z00(pix00))*sqrt(numel(pix00));
                    z00x = max(min(z00x,100),0);
                    idx00x = round(z00x*10)+1;
                    zObs(idx00x) = zObs(idx00x)+1;
                end
            end
            
            % false positive control
            suc = 0;
            zThr = 0;
            for mm=1:numel(zNull)
                if sum(zObs(mm:end))==0
                    break
                end
                fpr = sum(zNull(mm:end))/sum(zObs(mm:end));
                if fpr<0.01
                    suc = 1;
                    zThr = ceil(mm*1.2);
                    break
                end
            end
            
            % apply to data
            if suc>0
                for tt=1:size(dat,3)
                    z00 = zReal(:,:,tt);
                    tmp0 = tmpReal(:,:,tt);
                    cc = bwconncomp(tmp0);
                    ccSz = cellfun(@numel,cc.PixelIdxList);
                    for mm=1:numel(ccSz)
                        pix00 = cc.PixelIdxList{mm};
                        z00x = mean(z00(pix00))*sqrt(numel(pix00));
                        if z00x<zThr
                            tmp0(pix00) = 0;
                        end
                    end
                    dAR(:,:,tt) = dAR(:,:,tt) + tmp0;
                end
            end
            %zzshow(dAR);
            %keyboard
            dARAll = dARAll + dAR;
        end
    end
    
    dARAll = dARAll>0;
    arLst = bwconncomp(dARAll);
    arLst = arLst.PixelIdxList;
    
end


