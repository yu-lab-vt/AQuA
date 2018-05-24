% simulation with temporal oversample and downsample

% calcium kernel
% use decay tau to control rising/falling, thus duration
xxInc = 0:60;
yyInc = 1-exp(-xxInc/15);
xxDec = 1:100;
yyDec = exp(-xxDec/20);

% yy = [yyInc,yyDec];
% figure;plot(yy)

% data
% split rising and falling simulation
% density map

H = 64;
W = 64;
T = 300;
% dat = zeros(H,W,T);
dlyMap = nan(H,W);

for xx=5:60
    dlyMap(25:42,xx) = xx-4;
end

idxVec = find(~isnan(dlyMap));
dat = zeros(H*W,T);
for ii=1:numel(idxVec)
    idx = idxVec(ii);
    dly0 = dlyMap(idx);
    
    % propagation
    tmp = [zeros(1,dly0+30),yyInc,yyDec];   
    
    if numel(tmp)>T
        tmp = tmp(1:T);
    end
    dat(idx,1:numel(tmp)) = tmp;
end
dat = reshape(dat,H,W,T);

tStart = 10;
tGap = 20;
datS = dat(:,:,tStart:tGap:end);
zzshow(datS)

lmkMap = zeros(H,W);
lmkMap(29:38,29:38) = 1;
lmkMap(1:5,1:5) = 1;
zzshow(lmkMap)

lBorder = bwboundaries(lmkMap);
evts{1} = find(datS>0.5);

zzshow(datS>0.5)



















