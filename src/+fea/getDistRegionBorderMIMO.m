function resReg = getDistRegionBorderMIMO(evts,datS,regLst,lmkLst,muPerPix,minThr)
% getDistRegionBorder extract features related to regions drawn by user
% allow multiple landmark and multiple regions

resReg = [];
sz = size(datS);

nEvts = numel(evts);
nReg = numel(regLst);
nLmk = numel(lmkLst);

% --------------------------------- %
% landmarks
if ~isempty(lmkLst)
    % regions are flipped here
    [lMask,lCenter,lBorder,lAvgDist] = ui.detect.getPolyInfo(lmkLst,sz);
    
    resReg.landMark.mask = lMask;
    resReg.landMark.center = lCenter;
    resReg.landMark.border = lBorder;
    resReg.landMark.centerBorderAvgDist = lAvgDist*muPerPix;
    % distances to landmarks
    resReg.landmarkDist = fea.evt2lmkProp(evts,lBorder,sz,0,0,muPerPix);
    
    % frontier based propagation features related to landmark
    rr = fea.evt2lmkProp1Wrap(datS,evts,lMask,muPerPix,minThr);
    resReg.landmarkDir = rr;
else
    resReg.landMark = [];
    resReg.landmarkDist = [];
    resReg.landmarkDir = [];
end

% -------------------------------- %
% regions
if ~isempty(regLst)
    [rMask,rCenter,rBorder,rAvgDist] = ui.detect.getPolyInfo(regLst,sz);
    
    % landmark and region relationships
    if ~isempty(lmkLst)
        incluLmk = nan(nReg,nLmk);
        for ii=1:nReg
            map00 = rMask{ii};
            for jj=1:nLmk
                map11 = lMask{jj};
                map0011 = map00.*map11;
                if sum(map0011(:)>0)>0
                    incluLmk(ii,jj) = 1;
                end
            end
        end
    else
        incluLmk = [];
    end
    
    % distance to region boundary for events in a region
    memberIdx = nan(nEvts,nReg);
    dist2border = nan(nEvts,nReg);
    dist2borderNorm = nan(nEvts,nReg);
    % fprintf('Calculating distances to regions ...\n')
    for ii=1:length(evts)
        loc0 = evts{ii};
        [ih,iw,~] = ind2sub(sz,loc0);
        ihw = sub2ind([sz(1),sz(2)],ih,iw);
        flag = 0;
        for jj=1:nReg
            msk0 = rMask{jj};
            if sum(msk0(ihw))>0
                memberIdx(ii,jj) = 1;
                distPix2Pix = msk0*0;
                distPix2Pix(ihw) = 1;
                if flag==0
                    dd = regionprops(distPix2Pix,'Centroid');
                    dd = dd.Centroid;
                end
                flag = 1;
                cc = rBorder{jj};
                dist2border(ii,jj) = min(sqrt((dd(1)-cc(:,1)).^2 + (dd(2)-cc(:,2)).^2));
                dist2borderNorm(ii,jj) = dist2border(ii,jj)/rAvgDist(jj);
            end
        end
    end
    
    resReg.cell.mask = rMask;
    resReg.cell.center = rCenter;
    resReg.cell.border = rBorder;
    resReg.cell.centerBorderAvgDist = rAvgDist*muPerPix;
    resReg.cell.incluLmk = incluLmk;
    resReg.cell.memberIdx = memberIdx;
    resReg.cell.dist2border = dist2border*muPerPix;
    resReg.cell.dist2borderNorm = dist2borderNorm*muPerPix;
else
    resReg.cell = [];
end

end











