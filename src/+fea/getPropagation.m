function ftsPg = getPropagation(voli0,volr0,muPerPix,nEvt,ftsPg,useRev)
% getPropagation extract propagation features from events
% direction for each new pixel at each frame for given intensitythresholds
%
% TODO: allow user specified 'north'

[H,W,T] = size(voli0);
if T==1
    return
end
if useRev
    voli0 = voli0(:,:,T:-1:1);
    volr0 = volr0(:,:,T:-1:1);
end

% propagation direction vector
hDi = [-1,1,0,0];
wDi = [0,0,-1,1];

% propagation features
thr0 = 0.2:0.1:0.8;  % significant propagation (increase of reconstructed signal)
nThr = numel(thr0);
volr0(voli0==0) = 0;  % exclude values outside event
volr0(volr0<min(thr0)) = 0;

% time window for propagation
volr0Vec = reshape(volr0,[],T);
idx0 = find(max(volr0Vec,[],1)>min(thr0));
t0 = min(idx0);
t1 = max(idx0);

% propagation
prop = zeros(T,4,nThr);  % weighted distance for each frame and threshold (all directions)
ccLstPre = [];
ccMapPre = zeros(H,W);
for kk=1:nThr  % thresholds
    volr0k = volr0>thr0(kk);
    for tt=t0:t1  % time
        imgCur = volr0k(:,:,tt);
        cc = bwconncomp(imgCur);
        ccMapCur = labelmatrix(cc);
        ccLstCur = cc.PixelIdxList;
        for mm=1:numel(ccLstCur)  % connected components (cc) in this frame
            pix0 = ccLstCur{mm};
            idxPre = unique(ccMapPre(pix0));
            idxPre = idxPre(idxPre>0);
            if ~isempty(idxPre)  % previous cc overlap with this one
                cc1 = ccLstPre(idxPre);
                cc1Sz = cellfun(@numel,cc1);
                cc1 = cc1(cc1Sz>numel(pix0)*0.1);
                if ~isempty(cc1)  % previous cc large enough
                    mapNew = zeros(H,W);  % new pixels map
                    mapNew(pix0) = 1;
                    mapOld = zeros(H,W);  % existing pixels map
                    for mm1=1:numel(cc1)
                        mapOld(cc1{mm1}) = 1;
                        mapNew(cc1{mm1}) = 0;
                    end
                    [ihNew,iwNew] = find(mapNew>0);
                    [ihOld,iwOld] = find(mapOld>0);
                    if ~isempty(ihOld) && ~isempty(ihNew)        
                        dist01 = (ihNew-ihOld').^2+(iwNew-iwOld').^2;
                        [~,idxMin] = min(dist01,[],2);
                        dh01 = ihNew-ihOld(idxMin);
                        dw01 = iwNew-iwOld(idxMin);
                        for mm1=1:numel(wDi)  % direction
                            % map pixel direction to wanted direction
                            prop00 = sum([dw01,dh01].*[wDi(mm1),hDi(mm1)],2);
                            prop00(prop00<0) = 0;
                            prop(tt,mm1,kk) = prop(tt,mm1,kk)+sum(prop00);
                        end
                    end
                end                
            end
        end
        ccLstPre = ccLstCur;
        ccMapPre = ccMapCur;
    end
end

propGrowMultiThr = prop;
propGrow = nanmax(propGrowMultiThr,[],3);
propGrowOverall = nansum(propGrow,1);

if useRev
    propGrow(2:T,:) = propGrow(T:-1:2,:);
    ftsPg.propShrinkPix{nEvt} = propGrow*muPerPix;
    ftsPg.propShrinkPixOverall(nEvt,:) = propGrowOverall*muPerPix;    
else
    ftsPg.propGrowPix{nEvt} = propGrow*muPerPix;
    ftsPg.propGrowPixOverall(nEvt,:) = propGrowOverall*muPerPix;
end

end









