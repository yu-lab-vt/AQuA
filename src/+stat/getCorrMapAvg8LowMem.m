function [corrMap,actZMap,corrMapMed] = getCorrMapAvg8LowMem( dat, demedian, directionMask )
%GETCORRMAPAVG8 compute correlation map
% Each pixel with the average of its eight neighbors

if ~exist('demedian','var')
    demedian = 0;
end

if ~exist('directionMask','var')
    directionMask = [];
end

dat = double(dat);
[H, W, nTps] = size(dat);

dat1 = zeros(H,W,nTps);
for ii=1:8
    if sum(directionMask==ii)==0
        switch ii
            case 1
                dat1 = dat1 + [nan(1,W,nTps);nan(H-1,1,nTps),dat(1:end-1,1:end-1,:)];  % north west
            case 2
                dat1 = dat1 + [nan(H,1,nTps),dat(:,1:end-1,:)];  % west
            case 3
                dat1 = dat1 + [nan(H-1,1,nTps),dat(2:end,1:end-1,:);nan(1,W,nTps)];  % south west
            case 4
                dat1 = dat1 + [nan(1,W,nTps);dat(1:end-1,:,:)];  % north
            case 5
                dat1 = dat1 + [dat(2:end,:,:);nan(1,W,nTps)];  % south
            case 6
                dat1 = dat1 + [nan(1,W,nTps);dat(1:end-1,2:end,:),nan(H-1,1,nTps)];  % north east
            case 7
                dat1 = dat1 + [dat(:,2:end,:),nan(H,1,nTps)];  % east
            case 8
                dat1 = dat1 + [dat(2:end,2:end,:),nan(H-1,1,nTps);nan(1,W,nTps)];  % south east
        end
    end
end
dat1 = dat1/(8-length(directionMask));

% correlation coefficient
datMean = nanmean(dat,3);
datStd = nanstd(dat,0,3);
dat = bsxfun(@minus,dat,datMean);
dat = bsxfun(@rdivide,dat,datStd);

dat2Mean = nanmean(dat1,3);
dat2Std = nanstd(dat1,0,3);
dat1 = bsxfun(@minus,dat1,dat2Mean);
dat1 = bsxfun(@rdivide,dat1,dat2Std);

% corrMap = nanmax(dat.*dat2,[],3);
corrMap = nanmean(dat.*dat1,3);

corrMapMed = nanmedian(corrMap(:));
% corrMap = corrMap - corrMapMed;
if demedian
    corrMap = corrMap - corrMapMed;
end
actZMap = 0.5*log( (1+corrMap)./(1-corrMap))*sqrt(nTps-3);





