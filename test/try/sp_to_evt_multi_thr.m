%% super events
cOver = 0.1;
cDelay1 = 0;
cDelay = 10;
lblMapC = burst.sp2evtStp1(lblMapS,riseMap,cDelay1,cDelay,cOver,dat);
c1x = label2idx(lblMapC);

if 0
    ov1 = plt.regionMapWithData(lblMapC,dat.^2*0.3,0.25); zzshow(ov1);
end

bLst = label2idx(lblMapC);
s00 = sqrt(opts.varEst);

% initial rising time
idxSel = lblMapC(178,289,66);

% extract an super event
[ih,iw,it] = ind2sub([H,W,T],bLst{idxSel});
rgh = min(ih):max(ih);
rgw = min(iw):max(iw);
rgt = max(min(it)-1,1):min(max(it)+1,T);
dFx = dF(rgh,rgw,rgt);  % delta F
Lx = lblMapC(rgh,rgw,rgt);  % super event map
Sx = lblMapS(rgh,rgw,rgt);  % super voxel map
dFx(Lx>0 & Lx~=idxSel) = 0;
Sx(Lx>0 & Lx~=idxSel) = 0;

Mx = sum(Sx,3)>0;

SxMin = nanmin(Sx(:));
Sx(Sx>0) = Sx(Sx>0)-SxMin+1;
spLst0 = label2idx(Sx);

%% rising maps for different levels
[H0,W0,T0] = size(dFx);
thrVec = 1:6;
szVec = [16,8,8,8,8,8];  % !! pyramid is better?
tMapMT = zeros(H0,W0,numel(thrVec));
% ii = 4;
for ii=1:numel(thrVec)
    Rx = nan(size(dFx));
    
    dFxHi = dFx>thrVec(ii)*s00;
    dFxHi(Sx==0) = 0;
    dFxHi = bwareaopen(dFxHi,szVec(ii),8);
    M0 = sum(dFxHi,3)>0 & Mx;
    tMap = nan(H0,W0);
    for hh=1:H0
        for ww=1:W0
            if M0(hh,ww)
                x0 = squeeze(dFxHi(hh,ww,:));
                t0 = find(x0,1);
                if ~isempty(t0)
                    tMap(hh,ww) = t0;
                end
            end
        end
    end
    
    tMapMF = tMap;    
    mskDly = ~isnan(tMapMF);
    mskOut = 1-mskDly;
    [ihx,iwx] = find(mskOut>0);
    [ihy,iwy] = find(mskDly>0);
    spDlyMapx = tMapMF;
    for jj=1:numel(ihx)
        d00 = (ihx(jj)-ihy).^2+(iwx(jj)-iwy).^2;
        [~,ix] = min(d00);
        spDlyMapx(ihx(jj),iwx(jj)) = spDlyMapx(ihy(ix),iwy(ix));
    end
    tMapMF = medfilt2(spDlyMapx,[5,5],'symmetric');
    %tMapMF = imgaussfilt(tMapMF,1);
    tMapMF(mskOut>0) = nan;

    %tMapxx = tMap; tMapxx(tMap>70) = 70;
    %figure;imagesc(tMapxx,'AlphaData',~isnan(tMapxx));colorbar
    
    tMapxx = tMapMF; tMapxx(tMapxx>35) = 35;
    figure;imagesc(tMapxx,'AlphaData',~isnan(tMapxx));colorbar;pause(0.2)
    
    %tmp = zeros(H0,W0,3,T0); tmp(:,:,1,:) = dFxHi*0.4; tmp(:,:,2,:) = dFx;
    %zzshow(tmp);
    
    tMapMT(:,:,ii) = tMapMF;
end

%% seed candidates
cRise = 3;
cInt = 3;
burst.getLmFromRisingMultiThr(tMapMT,cRise,cInt,dFx,Sx,s00);

%% downsample and GTW
% For larger event, downsample make GTW feasible and smoother

H1 = round(numel(rgh)/4);
W1 = round(numel(rgw)/4);
dFxr = imresize(dFx,[H1,W1]);
Mxr = imresize(Mx,[H1,W1]);
% dFxrr = imresize(dFxr,[H,W]);

opts1 = opts;
opts1.gtwSmo = 0.1;
opts1.maxStp = 7;
res = burst.fitOnCr1(dFxrbi,opts1,1*(Mxr>0));








