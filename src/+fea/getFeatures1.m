function [ftsBase,ftsPg] = getFeatures1(voli0,volr0,muPerPix,nEvt,ftsBase,ftsPg)
% getFeatures extract local features from events

[H,W,T] = size(voli0);

% ftsBase = [];
% ftsPg = [];

% basic features
ftsBase.map{nEvt} = sum(voli0,3);
cc = regionprops(ftsBase.map{nEvt}>0,'Perimeter');
ftsBase.peri(nEvt) = sum([cc.Perimeter])*muPerPix;
cc = regionprops(ftsBase.map{nEvt}>0,'Area');
ftsBase.area(nEvt) = sum([cc.Area])*muPerPix*muPerPix;
ftsBase.circMetric(nEvt) = (ftsBase.peri(nEvt))^2/(4*pi*ftsBase.area(nEvt));

if T==1
    return
end

% propagation features
thr0 = 0.2:0.1:0.8;  % significant propagation (increase of reconstructed signal)
nThr = numel(thr0);
volr0(voli0==0) = 0;  % exclude values outside event
volr0(volr0<min(thr0)) = 0;
sigMap = sum(volr0>min(thr0),3);
nPix = sum(sigMap(:)>0);

% time window for propagation
volr0Vec = reshape(volr0,[],T);
idx0 = find(max(volr0Vec,[],1)>min(thr0));
t0 = min(idx0);
t1 = max(idx0);

% centroid of earlist frame as starting point
sigt0 = volr0(:,:,t0);
[ih,iw] = find(sigt0>min(thr0));
wt = sigt0(sigt0>min(thr0));
seedhInit = sum(ih.*wt)/sum(wt);
seedwInit = sum(iw.*wt)/sum(wt);
h0 = max(round(seedhInit),1);
w0 = max(round(seedwInit),1);

% mask for directions: north, south, west, east
msk = zeros(H,W,4);
msk(1:h0,:,1) = 1;
msk(h0:end,:,2) = 1;
msk(:,1:w0,3) = 1;
msk(:,w0:end,4) = 1;

% locations of centroid
sigDist = nan(T,4,nThr);  % weighted distance for each frame (four directions)
pixNum = zeros(T,nThr);  % pixel number increase
for tt=t0:t1
    imgCur = volr0(:,:,tt);
    for kk=1:nThr
        for ii=1:4
            imgCurThr = 1*(imgCur>thr0(kk));
            img0 = imgCurThr.*msk(:,:,ii);
            [ih,iw] = find(img0>0);
            if numel(ih)<4
                continue
            end
            seedh = mean(ih);
            seedw = mean(iw);
            switch ii
                case 1
                    sigDist(tt,1,kk) = seedhInit - seedh;
                case 2
                    sigDist(tt,2,kk) = seedh - seedhInit;
                case 3
                    sigDist(tt,3,kk) = seedwInit - seedw;
                case 4
                    sigDist(tt,4,kk) = seedw - seedwInit;
            end
        end
        pixNum(tt,kk) = sum(imgCur(:)>thr0(kk));        
    end
end

prop = nan(size(sigDist));
prop(2:end,:,:) = sigDist(2:end,:,:) - sigDist(1:end-1,:,:);

propGrowMultiThr = prop; 
propGrowMultiThr(propGrowMultiThr<0) = nan; 
propGrow = nanmax(propGrowMultiThr,[],3);
propGrowOverall = nansum(propGrow,1);

propShrinkMultiThr = prop; 
propShrinkMultiThr(propShrinkMultiThr>0) = nan; 
propShrink = nanmax(propShrinkMultiThr,[],3);
propShrinkOverall = nansum(propShrink,1);

pixNumChange = zeros(size(pixNum));
pixNumChange(2:end,:) = pixNum(2:end,:)-pixNum(1:end-1,:);
pixNumChangeRateMultiThr = pixNumChange/nPix;
pixNumChangeRate = max(pixNumChangeRateMultiThr,[],2);

% output
% use matrix (not cells) for 'overall' items
ftsPg.propGrow{nEvt} = propGrow*muPerPix;
ftsPg.propGrowOverall(nEvt,:) = propGrowOverall*muPerPix;
ftsPg.propShrink{nEvt} = propShrink*muPerPix;
ftsPg.propShrinkOverall(nEvt,:) = propShrinkOverall*muPerPix;
ftsPg.areaChange{nEvt} = pixNumChange*muPerPix*muPerPix;
ftsPg.areaChangeRate{nEvt} = pixNumChangeRate;

ftsPg.areaFrame{nEvt} = pixNum*muPerPix*muPerPix;

end









