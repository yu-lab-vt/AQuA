function [dat,dF,opts,H,W,T] = prep1(p0,f0,rgT,opts)
%PREP1 load data and estimation noise
% TODO: use segment by segment processing to reduce the impact of bleaching

bdCrop = opts.regMaskGap;

[filepath,name,ext] = fileparts([p0,filesep,f0]);
opts.filePath = filepath;
opts.fileName = name;
opts.fileType = ext;

% read data
fprintf('Reading data\n');
[dat,maxImg] = io.readTiffSeq([p0,filesep,f0]);
if exist('rgT','var') && ~isempty(rgT)
    dat = dat(:,:,rgT);
end
maxDat = max(dat(:));
dat = dat/maxDat;
dat = dat(bdCrop+1:end-bdCrop,bdCrop+1:end-bdCrop,:);
dat(dat<0) = 0;
if opts.usePG==1
    dat = sqrt(dat);
end
dat = dat + randn(size(dat))*1e-4;
[H,W,T] = size(dat);
opts.sz = [H,W,T];
opts.maxValueDepth = maxImg;
opts.maxValueDat = maxDat;

% noise estimation
[dF,stdEst,stdMapGau] = estNoisePerBlk(dat,opts.cut,opts.movAvgWin);

% noise and threshold
opts.varEst = stdEst.^2;
opts.varEstOrg = stdEst.^2;
opts.varMap = stdMapGau.^2;

opts.varEst = opts.varEstOrg;
tmp = load('./cfg/z01Order.mat'); opts.tbl = tmp.tbl;

end

function [dF,stdEst,stdMapGau] = estNoisePerBlk(datIn,cut,movAvgWin)
movAvg = load('./cfg/movAvgMin.mat');
tVecGap = movAvg.tVec(2)-movAvg.tVec(1);
[H,W,T] = size(datIn);
dF = zeros(H,W,T,'single');

stdEstVec = zeros(1,1);
stdMapGauVec = zeros(H,W,1);

nBlk = max(floor(T/cut*2),1);
for ii=1:nBlk
    fprintf('Prep block %d/%d\n',ii,nBlk)
    t0 = (ii-1)*round(cut/2)+1;
    if ii==nBlk
        t1 = T;
    else
        t1 = t0+cut-1;
    end
    dat = datIn(:,:,t0:t1);
    T1 = t1-t0+1;
    
    % noise level estimation
    [datMin,I] = min(movmean(dat,movAvgWin,3),[],3);
    stdMap = nan(H,W);
    for hh=1:H
        for ww=1:W
            i0 = I(hh,ww);
            s0 = max(i0-round(movAvgWin/2),1);
            s1 = min(i0+round(movAvgWin/2),T1);
            x = dat(hh,ww,s0:s1);
            stdMap(hh,ww) = std(x);
        end
    end
    % stdMapMed = medfilt2(stdMap,[7,7]);
    stdMapGau0 = imgaussfilt(stdMap,3);
    stdEstVec(ii) = nanmedian(stdMapGau0(:));
    stdMapGauVec(:,:,ii) = stdMapGau0;
    
    % bias for minimum of moving average
    sigLenMap = zeros(H,W)+T1*0.8;
    for kk=1:2
        tBias = movAvg.tBias(max(round((T1-sigLenMap)/tVecGap),1));        
        datMinC = datMin - tBias.*stdMapGau0;
        % datMinC = datMin - tBias*sqrt(varEst);
        dF0 = dat - datMinC;        
        dSig = (dF0 - 2*stdMapGau0)>0;
        dSig = bwareaopen(dSig,12,6);        
        sigLenMap = sum(dSig,3);
    end
    dF(:,:,t0:t1) = single(max(dF(:,:,t0:t1),dF0));
end

stdEst = mean(stdEstVec);
stdMapGau = mean(stdMapGauVec,3);

end




