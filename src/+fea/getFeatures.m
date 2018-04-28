function fts = getFeatures(vold0,voli0,volr0,muPerPix,fts,nEvt)
% getFeatures extract local features from events

thr0 = 0.2;  % significant propagation (increase of reconstructed signal)

if ~exist('fts','var')
    fts = [];
end
[H,W,T] = size(voli0);

% basic features
% fts.evtT = T;
fts.map{nEvt} = sum(voli0,3);
cc = regionprops(fts.map{nEvt}>0,'Perimeter');
fts.peri(nEvt) = sum([cc.Perimeter])*muPerPix;
cc = regionprops(fts.map{nEvt}>0,'Area');
fts.area(nEvt) = sum([cc.Area])*muPerPix*muPerPix;
fts.size(nEvt) = fts.area(nEvt);
fts.circMetric(nEvt) = (fts.peri(nEvt))^2/(4*pi*fts.area(nEvt));
vold0(voli0==0) = nan;
fts.evtBri(nEvt) = nanmedian(vold0(:));

if T==1
    return
end

% propagation features
volr0(voli0==0) = 0;  % exclude values outside voli0, usually outside candidate regions

pd = zeros(T,4);  % overall propagation distance for each time (four directions)
pdOrg = zeros(T,4);  % un-weighted
pdc = cell(T,1);  % propagation distance for each component of each time (four directions)
pdS = zeros(T,4);  % overall propagation distance for each time (four directions)

pdOrgS = zeros(T,4);  % un-weighted
pdcS = cell(T,1);  % propagation distance for each component of each time (four directions)
pixInc = zeros(T,1);  % pixel number increase
pixDec = zeros(T,1);  % pixel number decrease
pixChangeRatio = zeros(T,1);  % number of pixels changed divided by total active pixels
pixChangeRatioCurrent = zeros(T,1);  % number of pixels changed divided by current active pixels

sigMap = sum(volr0>thr0,3);
nPix = sum(sigMap(:)>0);

volr0Vec = reshape(volr0,[],T);
idx0 = find(sum(volr0Vec,1)>0);
t0 = min(idx0);
t1 = max(idx0);

for tt=t0+1:t1
    imgPre = volr0(:,:,tt-1);
    imgCur = volr0(:,:,tt);
    map0 = imgPre>thr0;
    map1 = imgCur>thr0;
    
    [ihx,iwx] = find(map0>0);
    if isempty(ihx)
        continue
    end
    ph0 = min(ihx); ph1 = max(ihx); pw0 = min(iwx); pw1 = max(iwx);
    [ihx,iwx] = find(map1>0);
    if isempty(ihx)
        continue
    end
    ch0 = min(ihx); ch1 = max(ihx); cw0 = min(iwx); cw1 = max(iwx);
    
    % pixel number increase, decrease and change ratio
    % consider expanding, shrinking and propagation
    inc0 = sum(map1(:)>map0(:));
    dec0 = sum(map0(:)>map1(:));
    pixInc(tt) = inc0*muPerPix*muPerPix;
    pixDec(tt) = dec0*muPerPix*muPerPix;
    pixChangeRatio(tt) = (inc0+dec0)/nPix;
    pixChangeRatioCurrent(tt) = (inc0+dec0)/max(sum(map0(:)),1);
    
    % each isolated part, pd0 is propagation distance along with intensity (as weight)
    % growing
    difxOrg = imgCur - imgPre;
    difx = difxOrg>thr0;
    difx(map0>0) = 0;
    difx = bwareaopen(difx,4);
    if max(difx(:))>0
        cc = bwconncomp(difx);
        pdc0 = zeros(cc.NumObjects,7);
        for ii=1:cc.NumObjects
            pix0 = cc.PixelIdxList{ii};
            [ih,iw] = ind2sub([H,W],pix0);
            h0 = min(ih); h1 = max(ih); w0 = min(iw); w1 = max(iw);
            pdc0(ii,1) = max(h1,ph1)-max(h0,ph1);  % south
            pdc0(ii,2) = min(h1,ph0)-min(h0,ph0);  % north
            pdc0(ii,3) = min(w1,pw0)-min(w0,pw0);  % west
            pdc0(ii,4) = max(w1,pw1)-max(w0,pw1);  % east
            pdc0(ii,5) = sum(difxOrg(pix0));  % sum of change
            pdc0(ii,6:7) = [mean(ih),mean(iw)];  % center of newly propagated region
        end
        pdc0 = pdc0*muPerPix;
        pdc0(:,5) = pdc0(:,5)*muPerPix;
        pdOrg(tt,:) = max(pdc0(:,1:4),[],1);
        pdc0Di = pdc0(:,1:4).*repmat(pdc0(:,5),1,4);
        pd(tt,:) = sum(pdc0Di,1);
        pdc{tt} = pdc0;
    end
        
    % shrinking
    difxOrg = imgPre - imgCur;
    difx = difxOrg>thr0;
    difx(map1>0) = 0;
    difx = bwareaopen(difx,4);
    if max(difx(:))>0
        cc = bwconncomp(difx);
        pdc0 = zeros(cc.NumObjects,7);
        for ii=1:cc.NumObjects
            pix0 = cc.PixelIdxList{ii};
            [ih,iw] = ind2sub([H,W],pix0);
            h0 = min(ih); h1 = max(ih); w0 = min(iw); w1 = max(iw);
            pdc0(ii,1) = min(h1,ch0)-min(h0,ch0);  % south
            pdc0(ii,2) = max(h1,ch1)-max(h0,ch1);  % north
            pdc0(ii,3) = max(w1,cw1)-max(w0,cw1);  % west
            pdc0(ii,4) = min(w1,cw0)-min(w0,cw0);  % east
            pdc0(ii,5) = sum(difxOrg(pix0));  % sum of change
            pdc0(ii,6:7) = [mean(ih),mean(iw)];  % center of newly propagated region
        end
        pdc0 = pdc0*muPerPix;
        pdc0(:,5) = pdc0(:,5)*muPerPix;
        pdOrgS(tt,:) = max(pdc0(:,1:4),[],1);
        pdc0Di = pdc0(:,1:4).*repmat(pdc0(:,5),1,4);
        pdS(tt,:) = sum(pdc0Di,1);
        pdcS{tt} = pdc0;
    end    
end

% normalize positive direction
% onset
fts.propDist{nEvt} = pd;
fts.propDistOrg{nEvt} = pdOrg;
fts.propDistComp{nEvt} = pdc;

pdPos = pdOrg*muPerPix;
pdPos(pdPos<0) = 0;
pdPosSum = sum(pdPos,1);
fts.propDirection4(nEvt,:) = pdPosSum;  % overall prop at 4 directions
fts.propDirection2(nEvt,:) = [pdPosSum(4)-pdPosSum(3),pdPosSum(2)-pdPosSum(1)];  % overall direction

pdPos = pdOrg;
pd13 = sqrt(pdPos(:,1).^2 + pdPos(:,3).^2);  % southwest
pd14 = sqrt(pdPos(:,1).^2 + pdPos(:,4).^2);  % southeast
pd23 = sqrt(pdPos(:,2).^2 + pdPos(:,3).^2);  % northwest
pd24 = sqrt(pdPos(:,2).^2 + pdPos(:,4).^2);  % northwest
pdDiag = [pd13,pd14,pd23,pd24];
fts.propDistDiag{nEvt} = pdDiag;
fts.propSpeedMax(nEvt) = max(pdDiag(:));

% offset
fts.propDistS{nEvt} = pdS;
fts.propDistOrgS{nEvt} = pdOrgS;
fts.propDistCompS{nEvt} = pdcS;

pdPos = pdOrgS;
pdPos(pdPos<0) = 0;
pdPosSum = sum(pdPos,1);
fts.propDirection4S(nEvt,:) = pdPosSum;  % overall prop at 4 directions
fts.propDirection2S(nEvt,:) = [pdPosSum(4)-pdPosSum(3),pdPosSum(2)-pdPosSum(1)];  % overall direction

pdPos = pdOrgS*muPerPix;
pd13 = sqrt(pdPos(:,1).^2 + pdPos(:,3).^2);  % southwest
pd14 = sqrt(pdPos(:,1).^2 + pdPos(:,4).^2);  % southeast
pd23 = sqrt(pdPos(:,2).^2 + pdPos(:,3).^2);  % northwest
pd24 = sqrt(pdPos(:,2).^2 + pdPos(:,4).^2);  % northeast
pdDiag = [pd13,pd14,pd23,pd24];
fts.propDistDiagS{nEvt} = pdDiag;
fts.propSpeedMaxS(nEvt) = max(pdDiag(:));

% output
fts.propPixInc{nEvt} = pixInc;
fts.propPixDec{nEvt} = pixDec;
fts.propPixChangeRatio{nEvt} = pixChangeRatio;
fts.propPixChangeRatioCurrent{nEvt} = pixChangeRatioCurrent;


end









