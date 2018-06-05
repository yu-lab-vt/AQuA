function [ regMap,zMap ] = growRegionNHST( zN, minSize, minSeedZ, minRegZ, bMean, bStd )
%GROWREGIONNHST Grow regions by order statistics based null hypothesis significance test

if ~exist('bMean','var')
    load('maxN01.mat','bMean','bStd');
end

[H,W] = size(zN);
seedIdx = find(zN>minSeedZ);

if isempty(seedIdx)
    zMap = zN;
    regMap = ones(size(zN));
    return
end

seedVal = zN(seedIdx);
[~,ix] = sort(seedVal,'descend');
seedIdx = seedIdx(ix);
regMap = zeros(H,W);
zMap = zN;

maxN01max = length(bMean);

regIdx = 1;
for ii=1:length(seedIdx)
    if mod(ii,100)==0
%         keyboard
        fprintf('Seed processed: %f\n',ii/length(seedIdx));
    end
    
    [ih,iw] = ind2sub([H,W],seedIdx(ii));
    if regMap(ih,iw)==0
        pixMapCur = zeros(H,W);
        pixMapCur(ih,iw) = 1;
        zMapCur = zeros(H,W);
        zMapCur(ih,iw) = zN(ih,iw);
        zCur = zN(ih,iw);
        nPixCnt = 1;
        
        % keep search neighbor pixels
        while 1
            % find neighbors, 4 or 8 connection?
            curMapDi = imdilate(pixMapCur,strel('square',3));
            curMapDi(pixMapCur>0) = 0;
            curMapDi(regMap>0) = 0;
            neibIdx = find(curMapDi>0);
            neibVal = zN(neibIdx);
            neibNum = min(length(neibVal),maxN01max);
            
            if neibNum<1
                break
            end
            
            % find best neighbor as candidate pixel to be added
            neibZ = (neibVal - bMean(neibNum))/bStd(neibNum);
            [neibBestVal,ix0] = max(neibZ);
            neibBestIdx = neibIdx(ix0);
            
            % update using corrected z score for the best pixel
            % the z score is the significance for the average of all pixels in this region
            zNew = (zCur*sqrt(nPixCnt)+neibBestVal)/sqrt(nPixCnt+1);
            
            % if the new pixel make the region less significant, stop
            if zNew<zCur
                break
            else
                zMapCur(neibBestIdx) = neibBestVal;
                zCur = zNew;
                pixMapCur(neibBestIdx) = 1;
                nPixCnt = nPixCnt + 1;
            end
        end
        
        % the region should be significant and large enough
        if sum(pixMapCur(:))>minSize && zCur>minRegZ
            regMap(pixMapCur>0) = regIdx;
            zMap(pixMapCur>0) = zCur;
            regIdx = regIdx + 1;
        end
    end
end

end

