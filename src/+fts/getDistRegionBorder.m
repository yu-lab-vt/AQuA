function fts = getDistRegionBorder(fts,loc,polyLst,sz)
% getDistRegionBorder extract features related to regions drawn by user

nPoly = length(polyLst);

polyMask = zeros(sz(1),sz(2),nPoly);
polyCenter = nan(nPoly,2);
polyBorder = cell(nPoly,1);  % boundary pixels
polyDist = nan(nPoly,1);
polyType = cell(nPoly,1);
for ii=1:nPoly
    poly0 = polyLst{ii}{1};
    if ~isempty(poly0)
        msk = poly2mask(poly0(:,1),poly0(:,2),sz(1),sz(2));
        cc = regionprops(msk,'Centroid');
        rCentroid = cc.Centroid;
        polyCenter(ii,:) = rCentroid;
        polyMask(:,:,ii) = msk;        
        mskBd = bwperim(msk);
        [ix,iy] = find(mskBd>0);
        polyBorder{ii} = [ix,iy];        
        polyDist(ii) = min(sqrt((rCentroid(1)-ix).^2 + (rCentroid(2)-iy).^2));
        polyType{ii} = polyLst{ii}{2};
    end
end

nEvts = length(loc);

% landmark and region relationships
% only region containing a landmark
incluLmk = nan(nPoly,1);
for ii=1:nPoly
    if strcmp(polyType{ii},'region')
        map00 = polyMask(:,:,ii);
        for jj=1:nPoly
            if strcmp(polyType{jj},'landmark')
                map11 = polyMask(:,:,jj);
                map0011 = map00.*map11;
                if sum(map0011(:)>0)>0
                    incluLmk(ii) = jj;
                end
            end
        end
    end
end

% distance to region boundary for events in the region
memberIdx = nan(nEvts,nPoly);
dist2border = nan(nEvts,nPoly);
dist2borderNorm = nan(nEvts,nPoly);
fprintf('Calculating distances to regions ...\n')
for ii=1:length(loc)
    loc0 = loc{ii};
    [ih,iw,~] = ind2sub(sz,loc0);
    ihw = sub2ind([sz(1),sz(2)],ih,iw);
    flag = 0;
    for jj=1:nPoly
        if ~isempty(polyLst{jj}) && strcmp(polyType{jj},'region')
            msk0 = polyMask(:,:,jj);
            if sum(msk0(ihw))>0
                memberIdx(ii,jj) = 1;                
                distPix2Pix = msk0*0;
                distPix2Pix(ihw) = 1;
                if flag==0
                    dd = regionprops(distPix2Pix,'Centroid');
                    dd = dd.Centroid;
                end
                flag = 1;
                cc = polyBorder{jj};
                dist2border(ii,jj) = min(sqrt((dd(1)-cc(:,1)).^2 + (dd(2)-cc(:,2)).^2));
                dist2borderNorm(ii,jj) = dist2border(ii,jj)/polyDist(jj);            
            end            
        end
    end    
end

% shortest distances (overall and per frame) and directions with respect to landmarks
% minimum distance between pixels of events and pixels of the landmark
dist2lmkPerFrame = cell(nEvts,1);
dist2lmkPerFrame1 = cell(nEvts,1);  % choose one region
dist2lmkPerFrameMean = nan(nEvts,nPoly);
direction2lmk = cell(nEvts,1);
direction2lmkMean = nan(nEvts,nPoly);
direction2lmkMeanPos = nan(nEvts,nPoly);
direction2lmkMeanNeg = nan(nEvts,nPoly);

% minimum distance between centroid of events and pixels of the landmark
dist2lmkPerFrameC = cell(nEvts,1);
dist2lmkPerFrame1C = cell(nEvts,1);  % choose one region
dist2lmkPerFrameMeanC = nan(nEvts,nPoly);
direction2lmkC = cell(nEvts,1);
direction2lmkMeanC = nan(nEvts,nPoly);
direction2lmkMeanPosC = nan(nEvts,nPoly);
direction2lmkMeanNegC = nan(nEvts,nPoly);

fprintf('Calculating distances to landmarks ...\n')
for ii=1:length(loc)
    if sum(~isnan(memberIdx(ii,:)))==0
        continue
    end
    loc0 = loc{ii};
    [ih,iw,it] = ind2sub(sz,loc0);
    nn = 0;
    distPix2Pix = nan(max(it)-min(it)+1,nPoly);
    distCen2Pix = nan(max(it)-min(it)+1,nPoly);
    for tt=min(it):max(it)
        ih0 = ih(it==tt);
        nn = nn + 1;
        if isempty(ih0)
            continue
        end
        iw0 = iw(it==tt);
        
        dd = [mean(ih0),mean(iw0)];
        
        for jj=1:nPoly
            if memberIdx(ii,jj)>0  % the region that this event belongs to
                if incluLmk(jj)>0  % the unique corresponding landmark
                    cc = polyBorder{incluLmk(jj)};
                    xx = min(sqrt((ih0'-cc(:,1)).^2 + (iw0'-cc(:,2)).^2));                    
                    distPix2Pix(nn,incluLmk(jj)) = min(xx(:));
                    xx = min(sqrt((dd(1)-cc(:,1)).^2 + (dd(2)-cc(:,2)).^2)); 
                    distCen2Pix(nn,incluLmk(jj)) = min(xx(:));
                end
            end
        end
    end
    
    % based on pixel
    if 1
        dist2lmkPerFrame{ii} = distPix2Pix;  % shortest distance to landmark at each frame        
        [~,ixx] = nanmin(nanmean(distPix2Pix,1));  % choose cloest landmark
        dist2lmkPerFrame1{ii} = distPix2Pix(:,ixx);        
        dist00 = nanmean(distPix2Pix,1);
        dist2lmkPerFrameMean(ii,:) = dist00;  % average distance to the landmark
        
        % cleaning
        for tt=1:size(distPix2Pix,1)
            for jj=1:nPoly
                if isnan(distPix2Pix(tt,jj))
                    if tt>1
                        distPix2Pix(tt,jj) = distPix2Pix(tt-1,jj);
                    end
                end
            end
        end
        
        % direction
        % positive values are propagating away from soma
        difx = distPix2Pix(2:end,:) - distPix2Pix(1:end-1,:);
        direction2lmk{ii} = difx;  % distance change at each frame comparing with the previous frame
        direction2lmkMean(ii,:) = nanmean(difx,1); % averge distance change
        difx1 = difx; difx1(difx1<0) = nan;
        direction2lmkMeanPos(ii,:) = nanmean(difx1,1);  % average positive distance change
        difx2 = difx; difx2(difx2>0) = nan;
        direction2lmkMeanNeg(ii,:) = nanmean(abs(difx2),1);  % average negative distance change
    end
    
    % based on centroid
    if 1
        dist2lmkPerFrameC{ii} = distCen2Pix;  % shortest distance to landmark at each frame        
        [~,ixx] = nanmin(nanmean(distCen2Pix,1));  % choose cloest landmark
        dist2lmkPerFrame1C{ii} = distCen2Pix(:,ixx);        
        dist00 = nanmean(distCen2Pix,1);
        dist2lmkPerFrameMeanC(ii,:) = dist00;  % average distance to the landmark
        
        % cleaning
        for tt=1:size(distCen2Pix,1)
            for jj=1:nPoly
                if isnan(distCen2Pix(tt,jj))
                    if tt>1
                        distCen2Pix(tt,jj) = distCen2Pix(tt-1,jj);
                    end
                end
            end
        end
        
        % direction
        % positive values are propagating away from soma
        difx = distCen2Pix(2:end,:) - distCen2Pix(1:end-1,:);
        direction2lmkC{ii} = difx;  % distance change at each frame comparing with the previous frame
        direction2lmkMeanC(ii,:) = nanmean(difx,1); % averge distance change
        difx1 = difx; difx1(difx1<0) = nan;
        direction2lmkMeanPosC(ii,:) = nanmean(difx1,1);  % average positive distance change
        difx2 = difx; difx2(difx2>0) = nan;
        direction2lmkMeanNegC(ii,:) = nanmean(abs(difx2),1);  % average negative distance change
    end
end


% fts = [];
fts.polyMask = polyMask;
fts.polyCenter = polyCenter;
fts.polyBorder = polyBorder;
fts.polyDist = polyDist;
fts.polyType = polyType;
fts.memberIdx = memberIdx;
fts.dist2border = dist2border;
fts.dist2borderNorm = dist2borderNorm;

fts.incluLmk = incluLmk;

% based on pixels
fts.dist2lmkPerFrameAll = dist2lmkPerFrame;
fts.dist2lmkPerFrame = dist2lmkPerFrame1;
fts.direction2lmk = direction2lmk;
fts.dist2lmkPerFrameMean = dist2lmkPerFrameMean;

fts.direction2lmkMeanAll = direction2lmkMean;
fts.direction2lmkMeanPosAll = direction2lmkMeanPos;
fts.direction2lmkMeanNegAll = direction2lmkMeanNeg;

fts.direction2lmkMean = nanmax(direction2lmkMean,[],2);
fts.direction2lmkMeanPos = nanmax(direction2lmkMeanPos,[],2);
fts.direction2lmkMeanNeg = nanmax(direction2lmkMeanNeg,[],2);

% based on centroid
fts.dist2lmkPerFrameAllC = dist2lmkPerFrameC;
fts.dist2lmkPerFrameC = dist2lmkPerFrame1C;
fts.direction2lmkC = direction2lmkC;
fts.dist2lmkPerFrameMeanC = dist2lmkPerFrameMeanC;

fts.direction2lmkMeanAllC = direction2lmkMeanC;
fts.direction2lmkMeanPosAllC = direction2lmkMeanPosC;
fts.direction2lmkMeanNegAllC = direction2lmkMeanNegC;

fts.direction2lmkMeanC = nanmax(direction2lmkMeanC,[],2);
fts.direction2lmkMeanPosC = nanmax(direction2lmkMeanPosC,[],2);
fts.direction2lmkMeanNegC = nanmax(direction2lmkMeanNegC,[],2);

end












