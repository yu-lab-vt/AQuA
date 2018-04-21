function tMapMT = getSuperEventRisingMapMultiThr(dFx,Sx,thrVec,s00)

[H0,W0,~] = size(dFx);

Mx = sum(Sx,3)>0;
SxMin = nanmin(Sx(:));
Sx(Sx>0) = Sx(Sx>0)-SxMin+1;

nVox = sum(Sx(:)>0);

% thrVec = 0:6;
szVec = zeros(size(thrVec))+4;
tMapMT = zeros(H0,W0,numel(thrVec));
for ii=1:numel(thrVec)
    if nVox>1e6; fprintf('%d\n',ii); end
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
%     mskDly = ~isnan(tMapMF);
%     %mskOut = 1-mskDly;
%     mskDlyDi = imdilate(mskDly,strel('square',7));
%     mskOut = mskDlyDi>0 & mskDly==0;
%     [ihx,iwx] = find(mskOut>0);
%     [ihy,iwy] = find(mskDly>0);
%     spDlyMapx = tMapMF;
%     for jj=1:numel(ihx)
%         d00 = (ihx(jj)-ihy).^2+(iwx(jj)-iwy).^2;
%         [~,ix] = min(d00);
%         spDlyMapx(ihx(jj),iwx(jj)) = spDlyMapx(ihy(ix),iwy(ix));
%     end
%     spDlyMapx(isnan(spDlyMapx)) = 0;
%     tMapMF = medfilt2(spDlyMapx,[5,5],'symmetric');
%     tMapMF = imgaussfilt(tMapMF,1);
%     tMapMF(mskOut>0) = nan;

    %tMapxx = tMap; tMapxx(tMap>70) = 70;
    %figure;imagesc(tMapxx,'AlphaData',~isnan(tMapxx));colorbar
    
    %tMapxx = tMapMF; tMapxx(tMapxx>35) = 35;
    %figure;imagesc(tMapxx,'AlphaData',~isnan(tMapxx));colorbar;pause(0.2)
    
    %tmp = zeros(H0,W0,3,T0); tmp(:,:,1,:) = dFxHi*0.4; tmp(:,:,2,:) = dFx;
    %zzshow(tmp);
    
    tMapMT(:,:,ii) = tMapMF;
end

end


