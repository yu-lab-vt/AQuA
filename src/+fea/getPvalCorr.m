function [p0,z0] = getPvalCorr(voxdIn,voxi,nn,~,minSeedZ,minRegZ,minSize,s00)
    
    validMap = sum(voxi==nn,3)>0;    
    if sum(validMap(:))>2000  % no need for significance control
        p0 = 0;
        z0 = 100;
        return
    end

    voxd = voxdIn;
    [H1,W1,T1] = size(voxd);
    
    if T1==1
        keyboard
    end
    
    voxd(voxi~=nn & voxi>0) = nan;

    % if T1<0
    %     gapx = 1000-T1;
    %     xAdd = ceil(gapx/2);
    %     preMap = zeros(H1,W1);
    %     postMap = zeros(H1,W1);
    %     for ii=1:H1
    %         for jj=1:W1
    %             %if validMap(ii,jj)>0
    %             x0 = voxd(ii,jj,:);
    %             %ix1 = find(~isnan(x0),1);
    %             %ix2 = find(~isnan(x0),1,'last');
    %             %preMap(ii,jj) = x0(ix1);
    %             %postMap(ii,jj) = x0(ix2);
    %             preMap(ii,jj) = nanmean(x0);
    %             postMap(ii,jj) = nanmean(x0);
    %             %end
    %         end
    %     end        
    %     dPre = repmat(preMap,1,1,xAdd);
    %     dPost = repmat(postMap,1,1,xAdd);        
    %     voxd = cat(3,dPre,voxd,dPost);
    %     voxd = voxd + randn(size(voxd))*s00;
    % end
    
    % distribution
    nTry = 10;
    tMap = zeros(H1,W1,nTry);
    for ii=1:nTry
        voxdn = voxd + randn(size(voxd))*s00;
        cMap = stat.getCorrMapAvg16( double(voxdn), ones(H1,W1) );
        %tMap(:,:,ii) = cMap;
        tMap(:,:,ii) = 0.5*log( (1+cMap)./(1-cMap) )*sqrt(size(voxdn,3)-3);
    end
    
    tMapMean = mean(tMap,3);
    tMapStd = std(tMap,0,3);
    zEmp = tMapMean./tMapStd;
    
    %[H1,W1,T1] = size(voxd);
    % vidVec = reshape(voxd,[],T1);
    % vidVec(validMap(:)==0,:) = nan;
    % voxd = reshape(vidVec,H1,W1,T1);
    
    % correlation map and z score
    cMap = stat.getCorrMapAvg16( double(voxd), ones(H1,W1) );
    z = 0.5*log( (1+cMap)./(1-cMap) )*sqrt(size(voxd,3)-3);

    %cMap = stat.getCorrMapAvg16( voxd, validMap );
    %cMap8 = stat.getCorrMapMax8(vidVST0,[]);    
    %cMap6 = cMap8(:,:,[1 3 4 5 6 8]);
    %cMap = nanmean(cMap6,3) - cBias;
    
    % region grow gives the z score for detected regions
    res0 = HTregionGrowingSuper(zEmp,validMap,minSeedZ,minRegZ,minSize,0);
    zMap = double(res0.connDmZmapSuper);
    z0 = max(zMap(:));
    p0 = 1-normcdf(z0);
    
    figure;
    subplot(1,2,1);imagesc(zEmp);colorbar
    subplot(1,2,2);imagesc(z);colorbar
    xMin = min(voxd(:));
    xMax = max(voxd(:));
    voxdShow = (voxd-xMin)./(xMax-xMin);
    zzshow(voxdShow);
    fprintf('z: %f t: %d\n',z0,T1);
    keyboard
    close all
end





