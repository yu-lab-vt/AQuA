function rr = evt2lmkProp1Wrap(dRecon,evts,lmkMsk)
% evt2lmkProp1Wrap extract propagation direciton related to landmarks
% call evt2lmkProp1 on each data patch

[H,W,T] = size(dRecon);

% landmarks
nEvts = numel(evts);
nLmk = numel(lmkMsk);
lmkLst = cell(nLmk,1);
for ii=1:nLmk
    %lmkMsk{ii} = flipud(lmkMsk{ii});
    lmkLst{ii} = find(lmkMsk{ii}>0);
end

% extract blocks
chgToward = zeros(nEvts,nLmk);
chgAway = zeros(nEvts,nLmk);
chgTowardBefReach = zeros(nEvts,nLmk);
chgAwayAftReach = zeros(nEvts,nLmk);

for nn=1:numel(evts)
    if mod(nn,100)==0; fprintf('%d\n',nn); end    
    evt0 = evts{nn};
    if isempty(evt0)
        continue
    end
    
    [h0,w0,t0] = ind2sub([H,W,T],evt0);
    rgH = min(h0):max(h0);
    rgW = min(w0):max(w0);
    rgT = min(t0):max(t0);
    H1 = numel(rgH);
    W1 = numel(rgW);
    T1 = numel(rgT);
    
    % data
    datS = dRecon(rgH,rgW,rgT);
    evt0 = sub2ind([H1,W1,T1],h0-rgH(1)+1,w0-rgW(1)+1,t0-rgT(1)+1);
    msk = zeros(size(datS));
    msk(evt0) = 1;
    datS = datS.*msk;
    
    % put landmark inside cropped event
    lmkMsk1 = cell(nLmk,1);
    for ii=1:nLmk
        [h0l,w0l] = ind2sub([H,W],lmkLst{ii});
        h00 = max(round(mean(h0l)),1);
        w00 = max(round(mean(w0l)),1);
        mskx = zeros(H,W);
        mskx(h00,w00) = 1;
        msk0 = mskx(rgH,rgW);
        ixx = find(msk0>0, 1);
        if ~isempty(ixx)
            lmkMsk1{ii} = msk0;
        else
            h0a = min(max(h00-rgH(1)+1,1),H1);
            w0a = min(max(w00-rgW(1)+1,1),W1);
            tmp = zeros(H1,W1);
            tmp(h0a,w0a) = 1;
            lmkMsk1{ii} = tmp;
        end
    end
    
    res1 = fts.evt2lmkProp1(datS,lmkMsk1);
    chgToward(nn,:) = res1.chgToward;
    chgAway(nn,:) = res1.chgAway;
    chgTowardBefReach(nn,:) = res1.chgTowardBefReach;
    chgAwayAftReach(nn,:) = res1.chgAwayAftReach;
end

rr.chgToward = chgToward;
rr.chgAway = chgAway;
rr.chgTowardBefReach = chgTowardBefReach;
rr.chgAwayAftReach = chgAwayAftReach;

end




