function [rr,res1] = evt2lmkProp1Wrap(dRecon,evts,lmkMsk,muPerPix,minThr)
% evt2lmkProp1Wrap extract propagation direciton related to landmarks
% call evt2lmkProp1 on each data patch

[H,W,T] = size(dRecon);

% m2 = muPerPix^2;
m3 = muPerPix^3;

thrRg = minThr:0.1:0.9;

% landmarks
nEvts = numel(evts);
nLmk = numel(lmkMsk);
lmkLst = cell(nLmk,1);
for ii=1:nLmk
    lmkLst{ii} = find(lmkMsk{ii}>0);
end

% extract blocks
chgToward = zeros(nEvts,nLmk);
chgAway = zeros(nEvts,nLmk);
chgTowardBefReach = zeros(nEvts,nLmk);
chgAwayAftReach = zeros(nEvts,nLmk);
pixTwd = cell(nEvts,1);
pixAwy = cell(nEvts,1);
chgTowardThr = zeros(nEvts,numel(thrRg),nLmk);
chgAwayThr = zeros(nEvts,numel(thrRg),nLmk);
chgTowardThrFrame = cell(nEvts,1);
chgAwayThrFrame = cell(nEvts,1);

for nn=1:numel(evts)
    if mod(nn,100)==0; fprintf('EvtLmk: %d\n',nn); end    
    evt0 = evts{nn};
    if isempty(evt0)
        continue
    end
    
    [h0,w0,t0] = ind2sub([H,W,T],evt0);
    rgH = max(min(h0)-2,1):min(max(h0)+2,H);
    rgW = max(min(w0)-2,1):min(max(w0)+2,W);
    rgT = min(t0):max(t0);
    H1 = numel(rgH);
    W1 = numel(rgW);
    T1 = numel(rgT);
    
    % data
    datS = dRecon(rgH,rgW,rgT);
    if isa(datS,'uint8')
        datS = double(datS)/255;
    end
    h0a = h0-rgH(1)+1;
    w0a = w0-rgW(1)+1;
    t0a = t0-rgT(1)+1;
    evt0 = sub2ind([H1,W1,T1],h0a,w0a,t0a);
    msk = zeros(size(datS));
    msk(evt0) = 1;
    datS = datS.*msk;
    
    % put landmark inside cropped event
    % if some part inside event box, use that part
    % for outside part, stick it to the border
    lmkMsk1 = cell(nLmk,1);
    for ii=1:nLmk
        [h0k,w0k] = ind2sub([H,W],lmkLst{ii});
        msk0 = zeros(H1,W1);
        h1k = h0k - min(rgH) + 1;
        w1k = w0k - min(rgW) + 1;
        h1ks = min(max(h1k,1),H1);
        w1ks = min(max(w1k,1),W1);
        msk0(h1ks,w1ks) = 1;
        lmkMsk1{ii} = msk0;
    end
    
    if nn==39
        %keyboard
    end
    
    res1 = fea.evt2lmkProp1(datS,lmkMsk1,thrRg);
    chgToward(nn,:) = res1.chgToward;
    chgAway(nn,:) = res1.chgAway;
    chgTowardBefReach(nn,:) = res1.chgTowardBefReach;
    chgAwayAftReach(nn,:) = res1.chgAwayAftReach;
    pixTwd{nn} = res1.pixelToward*muPerPix;
    pixAwy{nn} = res1.pixelAway*muPerPix;    
    chgTowardThr(nn,:,:) = res1.chgTowardThr;
    chgAwayThr(nn,:,:) = res1.chgAwayThr;
    chgTowardThrFrame{nn} = res1.chgTowardThrFrame*m3;
    chgAwayThrFrame{nn} = res1.chgAwayThrFrame*m3;
end

rr.chgToward = chgToward*m3;
rr.chgAway = chgAway*m3;
rr.chgTowardBefReach = chgTowardBefReach*m3;
rr.chgAwayAftReach = chgAwayAftReach*m3;
rr.pixelToward = pixTwd;
rr.pixelAway = pixAwy;

rr.chgTowardThr = chgTowardThr*m3;
rr.chgAwayThr = chgAwayThr*m3;
rr.chgTowardThrFrame = chgTowardThrFrame;
rr.chgAwayThrFrame = chgAwayThrFrame;

end




