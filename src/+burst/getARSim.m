function [arLst,dARAll] = getARSim(dat,opts,evtSpatialMask,smoMax,thrMin,minSize)

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

rto = size(dat,3)/size(dSim,3);

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
        
        % null
        tmpSim = dFSim>thrVec(jj)*sSim;
        szFreqNull = zeros(1,opts.sz(1)*opts.sz(2));
        for tt=1:size(dSim,3)
            tmp00 = tmpSim(:,:,tt).*evtSpatialMask;
            cc = bwconncomp(tmp00);
            ccSz = cellfun(@numel,cc.PixelIdxList);
            for mm=1:numel(ccSz)
                szFreqNull(ccSz(mm)) = szFreqNull(ccSz(mm))+1;
            end
        end
        szFreqNull = szFreqNull*rto;
        
        % observation
        tmpReal = dFReal>thrVec(jj)*sReal;
        szFreqObs = zeros(1,opts.sz(1)*opts.sz(2));
        for tt=1:size(dat,3)
            tmp00 = tmpReal(:,:,tt).*evtSpatialMask;
            cc = bwconncomp(tmp00);
            ccSz = cellfun(@numel,cc.PixelIdxList);  
            for mm=1:numel(ccSz)
                szFreqObs(ccSz(mm)) = szFreqObs(ccSz(mm))+1;
            end
        end
        
        % false positive control
        suc = 0;
        szThr = 0;
        for mm=1:opts.sz(1)*opts.sz(2)
            if sum(szFreqObs(mm:end))==0
                break
            end
            fpr = sum(szFreqNull(mm:end))/sum(szFreqObs(mm:end));
            if fpr<0.01
                suc = 1;
                szThr = ceil(mm*1.2);
                break
            end
        end
        szThr = max(szThr,minSize);
        
        % apply to data
        if suc>0
            e00 = round(smoVec(ii)/2);
            for tt=1:size(dat,3)
                tmp0 = tmpReal(:,:,tt).*evtSpatialMask;
                tmp0 = bwareaopen(tmp0,szThr);
                if e00>0
                    tmp0 = imerode(tmp0,strel('square',e00));
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


