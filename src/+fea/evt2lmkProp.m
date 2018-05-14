function rLmk = evt2lmkProp(evts,lmkBorder,sz,opSig,opPix,muPerPix)
% distances and directions between events and landmarks
%
% !!! Direction features are unreliable !!!
%
% opSig=0 : track whole pixels change
% opSig=1 : track increased pixels only
% opPix=0 : use minimum distances
% opPix=1 : use median distances (similar to centroid)

% op=1 : track minimum pixel wise distance
% op=2 : track changed pixels (we use increased pixels)

nEvt = numel(evts);
nLmk = numel(lmkBorder);

% distance to landmark
d2lmk = cell(nEvt,1);
d2lmkAvg = nan(nEvt,nLmk);
d2lmkMin = nan(nEvt,nLmk);

% propagation direction toward or away from landmark
% dir2lmk = cell(nEvt,1);
% dir2lmkAvg = nan(nEvt,nLmk);
% dir2lmkAvgPos = nan(nEvt,nLmk);
% dir2lmkAvgNeg = nan(nEvt,nLmk);

% fprintf('Calculating distances to landmarks ...\n')
for ii=1:length(evts)
    if mod(ii,100)==0
        fprintf('lmkDist: %d\n',ii)
    end
    loc0 = evts{ii};
    if isempty(loc0)
        continue
    end
    [ih,iw,it] = ind2sub(sz,loc0);
    tRg = min(it):max(it);
    distPix = nan(numel(tRg),nLmk);
    
    sigPre = [];
    for tt=1:numel(tRg)
        ixSel = it==tRg(tt);
        ih0 = ih(ixSel);
        if isempty(ih0)
            continue
        end
        iw0 = iw(ixSel);
        if opSig==1
            sigCur = sub2ind([sz(1),sz(2)],ih0,iw0);
            sigInc = setdiff(sigCur,sigPre);
            [ih0,iw0] = ind2sub([sz(1),sz(2)],sigInc);
            if ~isempty(sigCur)
                sigPre = sigCur;
            end
        end
        
        for jj=1:nLmk
            cc = lmkBorder{jj};
            if ~isempty(ih0)
                xx = min(sqrt((ih0'-cc(:,1)).^2 + (iw0'-cc(:,2)).^2));
            else
                xx = nan;
            end
            if opPix==0
                distPix(tt,jj) = min(xx(:));
            else
                distPix(tt,jj) = median(xx(:));
            end
        end
    end
    
    % cleaning
    for tt=1:size(distPix,1)
        for jj=1:nLmk
            if isnan(distPix(tt,jj))
                if tt>1
                    distPix(tt,jj) = distPix(tt-1,jj);
                end
            end
        end
    end
    
    % distance to landmark
    d2lmk{ii} = distPix*muPerPix;  % shortest distance to landmark at each frame
    d2lmkAvg(ii,:) = nanmean(distPix,1);  % average distance to the landmark
    d2lmkMin(ii,:) = nanmin(distPix,[],1);  % minimum distance to the landmark
    
%     % direction, positive values are propagating away from soma
%     if numel(tRg)>1
%         difx0 = distPix(2:end,:) - distPix(1:end-1,:);
%         difx0(isnan(difx0)) = 0;
%         difx = [zeros(1,size(difx0,2));difx0];
%     else
%         difx = distPix*0;
%     end
%     dir2lmk{ii} = difx;  % distance change at each frame comparing with the previous frame
%     dir2lmkAvg(ii,:) = nanmean(difx,1); % averge distance change
%     difx1 = difx; difx1(difx1<0) = nan;
%     dir2lmkAvgPos(ii,:) = nanmean(difx1,1);  % average positive distance change
%     difx2 = difx; difx2(difx2>0) = nan;
%     dir2lmkAvgNeg(ii,:) = nanmean(abs(difx2),1);  % average negative distance change
end

rLmk = [];
rLmk.distPerFrame = d2lmk;
rLmk.distAvg = d2lmkAvg*muPerPix;
rLmk.distMin = d2lmkMin*muPerPix;

% !!! below features unreliable !!!
% rLmk.distChgPerFrame = dir2lmk;
% rLmk.distChgAvg = dir2lmkAvg;
% rLmk.distChgAvgPos = dir2lmkAvgPos;
% rLmk.distChgAvgNeg = dir2lmkAvgNeg;

end







