function [corrMap,actZMap,corrMapMed] = getCorrMapAvg8( dat, demedian, directionMask )
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

% average of all neighbors
% !! how to avoid listing all directions?

% s = warning('error', 'MATLAB:catenate:DimensionMismatch');
% warning('error', 'MATLAB:catenate:DimensionMismatch');
try
    dat1 = zeros(H,W,nTps,8);
    dat1(:,:,:,1) = [nan(1,W,nTps);nan(H-1,1,nTps),dat(1:end-1,1:end-1,:)];  % north west
    dat1(:,:,:,2) = [nan(H,1,nTps),dat(:,1:end-1,:)];  % west
    dat1(:,:,:,3) = [nan(H-1,1,nTps),dat(2:end,1:end-1,:);nan(1,W,nTps)];  % south west
    dat1(:,:,:,4) = [nan(1,W,nTps);dat(1:end-1,:,:)];  % north
    dat1(:,:,:,5) = [dat(2:end,:,:);nan(1,W,nTps)];  % south
    dat1(:,:,:,6) = [nan(1,W,nTps);dat(1:end-1,2:end,:),nan(H-1,1,nTps)];  % north east
    dat1(:,:,:,7) = [dat(:,2:end,:),nan(H,1,nTps)];  % east
    dat1(:,:,:,8) = [dat(2:end,2:end,:),nan(H-1,1,nTps);nan(1,W,nTps)];  % south east
catch
    keyboard
end
% warning(s)

for ii=1:length(directionMask)
    dat1(:,:,:,directionMask(ii)) = NaN;
end

dat2 = nanmean(dat1,4);

% correlation coefficient
datMean = nanmean(dat,3);
datStd = nanstd(dat,0,3);
dat = bsxfun(@minus,dat,datMean);
dat = bsxfun(@rdivide,dat,datStd);

dat2Mean = nanmean(dat2,3);
dat2Std = nanstd(dat2,0,3);
dat2 = bsxfun(@minus,dat2,dat2Mean);
dat2 = bsxfun(@rdivide,dat2,dat2Std);

% corrMap = nanmax(dat.*dat2,[],3);
corrMap = nanmean(dat.*dat2,3);

corrMapMed = nanmedian(corrMap(:));
% corrMap = corrMap - corrMapMed;
if demedian
    corrMap = corrMap - corrMapMed;
end
actZMap = 0.5*log( (1+corrMap)./(1-corrMap))*sqrt(nTps-3);





