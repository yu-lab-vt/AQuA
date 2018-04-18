function [pVal,zx] = getRegionScoreHTRG( vidVST,vidIdx,loc,minSize,minSeedZ,minRegZ,opts,zBias)
%getRegionScoreHTRG Compute z-score for each region using hypothesis testing region grow

% minSeedZ = 4;
% minRegZ = 8;

if ~exist('zBias','var')
    zBias = 0;
end

T = min(size(vidVST,3),100);
vidVST = vidVST + randn(size(vidVST))*1e-6;

vid0 = vidVST(:,:,1:T);
cMap8 = glia.getCorrMapMax8(vid0,[]);
cMap6 = cMap8(:,:,[1 3 4 5 6 8]);
cMap = nanmean(cMap6,3);
cBias = max(median(cMap(:)),0);

% bMean = opts.bMean;
% bStd = opts.bStd;

lMax = max(vidIdx(:));
[H,W,T] = size(vidVST);
zx = zeros(1,lMax);
xyGap = 3;
zExtTgt = 5;
pVal = nan(1,lMax);

for nn=1:lMax
    if mod(nn,1000)==0
        fprintf('N: %d\n',nn)
    end
    loc0 = loc{nn};
    if ~isempty(loc0)
        % extract this event or candidate region
        [ix,iy,iz] = ind2sub([H,W,T],loc0);
        xMin = max(min(ix)-xyGap,1); xMax = min(max(ix)+xyGap,H);
        yMin = max(min(iy)-xyGap,1); yMax = min(max(iy)+xyGap,W);
        
        zLen = max(iz) - min(iz);
        zExt = max(round(zLen/2),zExtTgt);
        zMin = max(min(iz)-zExt,1); zMax = min(max(iz)+zExt,T);
        
        vidIdx0 = vidIdx(xMin:xMax,yMin:yMax,zMin:zMax);
        vidVST0 = vidVST(xMin:xMax,yMin:yMax,zMin:zMax);
        vidVST0(vidIdx0~=nn & vidIdx0>0) = nan;
        [H1,W1,T1] = size(vidVST0);
        spatialMap = sum(vidIdx0==nn,3)>0;
        vidVec = reshape(vidVST0,[],T1);
        vidVec(spatialMap(:)==0,:) = nan;
        vidVST0 = reshape(vidVec,H1,W1,T1);
        
        % correlation map use the maximum of eight directions
        cMap8 = glia.getCorrMapMax8(vidVST0,[]);
        
        cMap6 = cMap8(:,:,[1 3 4 5 6 8]);
        cMap = nanmean(cMap6,3) - cBias;
        %cMap = max(cMap6,[],3);
        %cMap = max(cMap8,[],3);
        z = 0.5*log( (1+cMap)./(1-cMap) )*sqrt(size(vidVST0,3)-3) - zBias;
        zN = z;
        
        % due to selection bias, the z scores follow a new null distribution
        % zN follows N(0,1) in null
        %zN = (z - bMean(6))/bStd(6);
        % figure;imshow(zN/10);
        % figure;imshow(zN>minSeedZ)
        
        % region grow gives the z score for detected regions
        res0 = HTregionGrowingSuper(zN,spatialMap,minSeedZ,minRegZ,minSize,0);
        zMap = double(res0.connDmZmapSuper);
        zx(nn) = max(zMap(:));
        
%         [ ~,zMap ] = glia.growRegionNHST( zN, minSize, minSeedZ, minRegZ, bMean, bStd );
%         spatialMap = sum(vidIdx0==nn,3)>0;
%         zx(nn) = max(zMap(spatialMap));

        pVal(nn) = 1-normcdf(zx(nn));
    end
end

end




