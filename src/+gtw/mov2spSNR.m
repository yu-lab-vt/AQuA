function [spLst,spSeedVec,spSz,spSco,spStd,spStatus] = mov2spSNR(dF,dFInfo,tMapMT,availMap,snrThr,gaphw,s00)
% mov2spSNR make delta F movie to super pixels with similar SNR
% For weak signals, enlarge search space

[H,W,T] = size(dF);

% snrThr = 10;
% gaphw = 10;

xSim = movmean(randn(10000,T),5,2);
xMax = max(xSim,[],2);
xMaxBias = mean(xMax);

% availMap = m0s>0;
[dIx,dIix] = sort(dFInfo(:),'descend');
mapx = zeros(H,W);
mapx(dIix) = 1:H*W;
dIx(mapx(availMap==0)) = 0;
availMapx = availMap;
% availMapBak = availMap;

spLst = cell(0);
spSeedVec = zeros(0);  % seed location for each event
spStd = zeros(0);  % nosie level for each event
spSco = zeros(0);  % score for this event (final SNR)
spSz = zeros(0);
spStatus = zeros(0);  % 1: use others places

nSp = 1;
for nn=1:numel(dIx)
    if dIx(nn)==0
        continue
    end
    iSeedIn = dIix(nn);
    
    % extract region
    [ihSeed,iwSeed] = ind2sub([H,W],iSeedIn);
    rgh = max(ihSeed-gaphw,1):min(ihSeed+gaphw,H);
    rgw = max(iwSeed-gaphw,1):min(iwSeed+gaphw,W);
    H1 = numel(rgh);
    W1 = numel(rgw);
    ihSeed = ihSeed-min(rgh)+1;
    iwSeed = iwSeed-min(rgw)+1;
    iSeed = sub2ind([H1,W1],ihSeed,iwSeed);
    
    df0 = dF(rgh,rgw,:);
    df0Vec = reshape(df0,[],T);
    
    ft = tMapMT(rgh,rgw,:);
    availMap0 = availMapx(rgh,rgw);
    availMap0(ihSeed,iwSeed) = false;
    
    % distances: delay, intensity and distance
    ftBase = reshape(ft(ihSeed,iwSeed,:),1,[]);
    if sum(~isnan(ftBase))==0
        continue
    end
    ftVec = reshape(ft,[],size(ft,3));
    distDelay = nanmedian(abs(ftVec - ftBase),2);
    distDelay(isnan(distDelay)) = Inf;
    distInt = abs(sum(isnan(ftVec),2)-sum(isnan(ftBase)));
    [ih1,iw1] = find(ones(H1,W1));
    distEuc = sqrt((ihSeed-ih1).^2+(iwSeed-iw1).^2);
    distx = distDelay+distInt*0.5+distEuc*2;
    distx = reshape(distx,H1,W1);
    %figure;imagesc(distx,'AlphaData',~isinf(distx));colorbar
    
    % region growing
    neibSet = [];
    newPix = iSeed;
    pixSet = iSeed;
    status = 0;
    for ii=1:100
        % SNR
        xm = mean(df0Vec(pixSet,:),1);
        %sNow = sqrt(median((xm(2:end)-xm(1:end-1)).^2)/0.9113);
        sNow = s00/sqrt(numel(pixSet));  % more stable than re-calculating
        xm = movmean(xm,5);
        xMax = max(xm) - xMaxBias*sNow;
        snrNow = xMax/sNow;
        if snrNow>=snrThr && numel(pixSet)>=4  % enough information and location
            break
        end
        
        [ih2,iw2] = ind2sub([H1,W1],newPix);
        h00 = [min(ih2+1,H1),max(ih2-1,1),ih2,ih2];
        w00 = [iw2,iw2,max(iw2-1,1),min(iw2+1,W1)];
        newCand = unique(sub2ind([H1,W1],h00,w00));
        newCand = newCand(availMap0(newCand));
        neibSet = union(neibSet,newCand);
        if isempty(neibSet)  % no new neighbors
            status = 1;
            break
        end
        neibDist = distx(neibSet);
        [~,ix] = min(neibDist);
        newPix = neibSet(ix);
        availMap0(newPix) = false;
        pixSet = union(pixSet,newPix);
        neibSet = setdiff(neibSet,newPix);
    end
    
    availMapx(rgh,rgw) = availMapx(rgh,rgw).*availMap0;
    [ihx,iwx] = ind2sub([H1,W1],pixSet);
    spLst0 = sub2ind([H,W],ihx+min(rgh)-1,iwx+min(rgw)-1);
    dIx(mapx(spLst0)) = 0;
    %pixMap = zeros(H1,W1); pixMap(pixSet) = 1; zzshow(pixMap)
    
    if snrNow<min(snrThr/4,3)
        continue
    end
    
    spStd(nSp) = sNow;
    spSco(nSp) = snrNow;
    spStatus(nSp) = status;
    spSz(nSp) = numel(pixSet);
    
    spSeedVec(nSp) = iSeedIn;
    spLst{nSp} = spLst0;
    %ov0 = plt.regionMapWithData(spLst,zeros(H0,W0),0.5); zzshow(ov0);
    nSp = nSp+1;
    if mod(nSp,1000)==0
        fprintf('%d\n',nSp)
        %         break
    end
end

% add unused pixels to super pixels
spMap = zeros(H,W);
for nn=1:numel(spLst)
    spMap(spLst{nn}) = nn;
end
for kk=1:100
    idx = find(spMap==0 & availMap>0);
    if isempty(idx)
        break
    end
    for ii=1:numel(idx)
        idx0 = idx(ii);
        [ih,iw] = ind2sub([H,W],idx0);
        rgh = max(ih-1,1):min(ih+1,H);
        rgw = max(iw-1,1):min(iw+1,W);
        ix = spMap(rgh,rgw);
        ix = ix(ix>0);
        if ~isempty(ix)
            spMap(idx0) = ix(1);
        end
    end
end
spLst = label2idx(spMap);
spSz = cellfun(@numel,spLst);

end









