function cMap8 = getCorrMapMax8( dat, directionAvoid )
%getCorrMapMax8 compute correlation map
% Take the maximum of eight direction correlations and correct with order statistics
% Allow missing values

dat = double(dat);
[H, W, nTps] = size(dat);

datMean = nanmean(dat,3);
datStd = nanstd(dat,0,3);
dat = bsxfun(@minus,dat,datMean);
dat = bsxfun(@rdivide,dat,datStd);

% correlation on eight directions
cMap8 = zeros(H,W,8);
masks = ones(1,8);
masks(directionAvoid) = 0;
for ii=1:8
    if masks(ii)>0
        switch ii
            case 1
                dat1 = [nan(1,W,nTps);nan(H-1,1,nTps),dat(1:end-1,1:end-1,:)];  % north west
            case 2
                dat1 = [nan(H,1,nTps),dat(:,1:end-1,:)];  % west
            case 3
                dat1 = [nan(H-1,1,nTps),dat(2:end,1:end-1,:);nan(1,W,nTps)];  % south west
            case 4
                dat1 = [nan(1,W,nTps);dat(1:end-1,:,:)];  % north
            case 5
                dat1 = [dat(2:end,:,:);nan(1,W,nTps)];  % south
            case 6
                dat1 = [nan(1,W,nTps);dat(1:end-1,2:end,:),nan(H-1,1,nTps)];  % north east
            case 7
                dat1 = [dat(:,2:end,:),nan(H,1,nTps)];  % east
            case 8
                dat1 = [dat(2:end,2:end,:),nan(H-1,1,nTps);nan(1,W,nTps)];  % south east                
            otherwise
                error('Only allow eight directions')
        end        
        dat1Mean = nanmean(dat1,3);
        dat1Std = nanstd(dat1,0,3);
        dat1 = bsxfun(@minus,dat1,dat1Mean);
        dat1 = bsxfun(@rdivide,dat1,dat1Std);        
        c0 = nanmean(dat.*dat1,3);
        c0(c0<-1) = -0.9;
        c0(c0>1) = 0.9;
%         if max(c0(:))>1
%             keyboard
%         end        
        cMap8(:,:,ii) = c0;
    end
end






