function ftsPg = getPropagationPixTracing(voli0,volr0,muPerPix,nEvt,ftsPg,northDi,useRev,dbg)
% getPropagation extract propagation features from events
% direction for each new pixel at each frame for given intensitythresholds
%
% TODO: allow user specified 'north'

if ~exist('dbg','var')
    dbg = 0;
end

[H,W,T] = size(voli0);
if T==1
    return
end

% make coordinate correct
voli0 = voli0(end:-1:1,:,:);
volr0 = volr0(end:-1:1,:,:);
if useRev
    voli0 = voli0(:,:,T:-1:1);
    volr0 = volr0(:,:,T:-1:1);
end

% propagation direction vector
a = northDi(1);
b = northDi(2);
kDi = zeros(4,2);
kDi(1,:) = [a,b];
kDi(2,:) = [-a,-b];
kDi(3,:) = [-b,a];
kDi(4,:) = [b,-a];
hDi = kDi(:,2);
wDi = kDi(:,1);

% propagation features
thr0 = 0.2:0.1:0.8;  % significant propagation (increase of reconstructed signal)
nThr = numel(thr0);
volr0(voli0==0) = 0;  % exclude values outside event
volr0(volr0<min(thr0)) = 0;

% down sample for faster calculation
if H*W>10000
    sck = sqrt(10000/H/W);
    volr0Ds = imresize(volr0,sck);
else
    sck = 1;
    volr0Ds = volr0;
end
[H,W,T] = size(volr0Ds);

% time window for propagation
volr0Vec = reshape(volr0Ds,[],T);
idx0 = find(max(volr0Vec,[],1)>min(thr0));
t0 = min(idx0);
t1 = max(idx0);

% propagation
prop = zeros(T,4,nThr);  % weighted distance for each frame and threshold (all directions)
ccLstPre = [];
ccMapPre = zeros(H,W);

nTot = 0; nTie = 0; pOverA = zeros(1,4); pOverB = zeros(1,4);  % influence of tie

for kk=1:nThr  % thresholds
    volr0k = volr0Ds>thr0(kk);
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
                    [ihOld,iwOld] = find(mapOld>0);  % FIXME: permute ihOld and iwOld to reduce bias
                    
                    if ~isempty(ihOld) && ~isempty(ihNew)        
                        dist01 = (ihNew-ihOld').^2+(iwNew-iwOld').^2;
                        [xMin,idxMin] = min(dist01,[],2);
                        
                        % ===========
                        % count tie and the angle shift
                        if useRev==0 && dbg>0
                            for ii=1:numel(xMin)
                                tmp = dist01(ii,:);
                                ix00 = find( (tmp-xMin(ii)).^2<=1e-8 );
                                nTot = nTot+1;
                                if rand(1)>0.5
                                    ixOrd = [1,2];
                                else
                                    ixOrd = [2,1];
                                end
                                if numel(ix00)>1
                                    dh01x = ihNew(ii)-ihOld(ix00(ixOrd(1)));
                                    dw01x = iwNew(ii)-iwOld(ix00(ixOrd(1)));
                                    for mm1=1:numel(wDi)  % direction
                                        prop00 = sum([dw01x,dh01x].*[wDi(mm1),hDi(mm1)]);
                                        prop00(prop00<0) = 0;
                                        pOverA(mm1) = pOverA(mm1)+prop00;
                                    end
                                    dh01x = ihNew(ii)-ihOld(ix00(ixOrd(2)));
                                    dw01x = iwNew(ii)-iwOld(ix00(ixOrd(2)));
                                    for mm1=1:numel(wDi)  % direction
                                        prop00 = sum([dw01x,dh01x].*[wDi(mm1),hDi(mm1)]);
                                        prop00(prop00<0) = 0;
                                        pOverB(mm1) = pOverB(mm1)+prop00;
                                    end
                                    nTie = nTie+1;
                                end
                            end
                        end
                        % ===========
                                                
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

sck1 = sck.^3;
if useRev
    propGrow(2:T,:) = propGrow(T:-1:2,:);
    ftsPg.propShrinkPix{nEvt} = propGrow*muPerPix/sck1;
    ftsPg.propShrinkPixOverall(nEvt,:) = propGrowOverall*muPerPix/sck1;
else
    ftsPg.propGrowPix{nEvt} = propGrow*muPerPix/sck1;
    ftsPg.propGrowPixOverall(nEvt,:) = propGrowOverall*muPerPix/sck1;
    if dbg>0
        ftsPg.test.nTot(nEvt) = nTot;
        ftsPg.test.nTie(nEvt) = nTie;
        ftsPg.test.pOverA(nEvt,:) = pOverA;
        ftsPg.test.pOverB(nEvt,:) = pOverB;
    end
end

end









