function [lblMapS,dRecon,riseX,riseXv,riseXn] = alignPatchShort(dat,datSmo,lblMapF,opts)
% alignPatch Re-align pixels in each patch, divide large ones to super
% pixels and estimate the delay

spSz = opts.spSz;
[H,W,T] = size(dat);
voxLst = label2idx(lblMapF);
dRecon = zeros(H,W,T);

% early events first. The tail is less reliable. Later events can eat the tail.
tVec = Inf(numel(voxLst),1);
for nn=1:numel(voxLst)
    vox = voxLst{nn};
    if ~isempty(vox)
        [~,~,it0] = ind2sub([H,W,T],vox);
        tVec(nn) = min(it0);
    end
end
[~,dlyOrder] = sort(tVec,'ascend');

lblMapS = zeros(H,W,T);
riseX = nan(0,1);
riseXv = nan(0,1);
riseXn = nan(0,1);
nCnt = 1;
gaph = 10;  % larger value made superpixel easier
for nn=1:numel(voxLst)
%     if mod(nn,100)==0
%         fprintf('%d\n',nn)
%     end
    vox = voxLst{dlyOrder(nn)};
    if isempty(vox)
        continue
    end
    [ih1,iw1,~] = ind2sub([H,W,T],vox);
    rgH1 = max(min(ih1)-gaph,1):min(max(ih1)+gaph,H);
    rgW1 = max(min(iw1)-gaph,1):min(max(iw1)+gaph,W);
    H1 = numel(rgH1);
    W1 = numel(rgW1);
    ih1a = ih1 - min(rgH1) + 1;
    iw1a = iw1 - min(rgW1) + 1;
    ihw1 = unique(sub2ind([H1,W1],ih1a,iw1a));
    validMap1 = zeros(H1,W1);
    validMap1(ihw1) = 1;
    
    dat1 = dat(rgH1,rgW1,:);
    lbl1 = lblMapF(rgH1,rgW1,:);
    dat1Smo = datSmo(rgH1,rgW1,:);
    dat1Vec = reshape(dat1,[],T);
    dat1SmoVec = reshape(dat1Smo,[],T);
    lbl1Vec = reshape(lbl1,[],T);
    
    tw1Vec = zeros(H1*W1,T);
    
    % for each pixel, replace time points from other events by baseline
    tBegin = T;
    tEnd = 1;
    for ii=1:size(dat1SmoVec,1)
        if validMap1(ii)==0
            continue
        end
        lblOnePix = lbl1Vec(ii,:);
        dat1SmoOnePix = dat1SmoVec(ii,:);
        dat1OnePix = dat1Vec(ii,:);
        
        % time for previous or next events
        t0 = find(lblOnePix==dlyOrder(nn),1);
        t1 = find(lblOnePix==dlyOrder(nn),1,'last');
        t0p = find(lblOnePix(1:max(t0-1,1))>0,1,'last');
        if isempty(t0p)
            t0p = 1;
        end
        dt1p = find(lblOnePix(min(t1+1,T):end)>0,1);
        if ~isempty(dt1p)
            t1p = min(dt1p + t1,T);
        else
            t1p = T;
        end
        
        % lowest point between events
        [x0,t0a] = min(dat1SmoOnePix(t0p:t0));
        [x1,dt1a] = min(dat1SmoOnePix(t1:t1p));
        t1a = dt1a + t1 - 1;
        
        % signal low enough
        t0b = t0a;
        t1b = t1a;
        for tt=t0:-1:t0a
            if dat1SmoOnePix(tt)<x0+sqrt(opts.varEst)
                t0b = tt;
                break
            end
        end
        for tt=t1:t1a
            if dat1SmoOnePix(tt)<x1+sqrt(opts.varEst)
                t1b = tt;
                break
            end
        end        
        
        dat1OnePix(1:t0b) = x0;
        dat1OnePix(t1b:end) = x1;
        dat1Vec(ii,:) = dat1OnePix;
        
        %tBegin = min(tBegin,t0b);
        %tEnd = max(tEnd,t1b);
        
        tBegin = min(tBegin,t0);
        tEnd = max(tEnd,t1);
        
        % do not consider falling
        tw1Vec(ii,t0:t1) = 1;
        %tw1Vec(ii,t0b:t1) = 1;
    end
    
    % fitting
    rgT = tBegin:tEnd;
    if numel(rgT)<3  % in case signal too short
        rgT = max(tBegin-2,1):min(tEnd+2,T);
    end
    
    dat1a = reshape(dat1Vec,H1,W1,T);
    dat1a = dat1a(:,:,rgT);
%     opts.gtwSmo = 1;
    validMap2 = imdilate(validMap1,strel('square',3));
%     try
        res = burst.fitOnCr1(dat1a,opts,validMap2);
%     catch
%         warning('ALIGN %d\n',nn);
% %         continue
% %         keyboard
%     end
    
    % super pixels delay
    dMapS = res.dMapS;    
    if numel(ihw1)<2*spSz
        L = validMap1;
        dlyReg = nanmean(dMapS(L>0));
        dlyRegV = nanstd(dMapS(L>0));
        dlyRegN = nansum(L(:)>0);
    else
        nSP = round(H1*W1/spSz);
        A = dMapS - nanmin(dMapS(:));
        A = A./(nanmax(A(:))+1);
        A(isnan(A)) = -100;
        [Lsp,~] = superpixels(A,nSP);
        Lsp(isnan(dMapS) | validMap1==0) = 0;
        
        Lidx = label2idx(Lsp);
        Lidx = Lidx(~cellfun(@isempty,Lidx));
        
        L = zeros(H1,W1);
        nSP = numel(Lidx);
        dlyReg = nan(1,nSP);
        dlyRegV = nan(1,nSP);
        dlyRegN = nan(1,nSP);
        for ii=1:nSP
            pix0 = Lidx{ii};
            L(pix0) = ii;
            dlyReg(ii) = nanmean(dMapS(pix0));
            dlyRegV(ii) = nanstd(dMapS(pix0));
            dlyRegN(ii) = numel(pix0);
        end
    end
    dlyReg = res.tEvtUp - dlyReg + min(rgT) - 1;
    
    % gather results
    datWarp = res.datWarp;
    pixLst = label2idx(L);
    for ii=1:numel(pixLst)
        pix0 = pixLst{ii};       
        if numel(pix0)<4
            continue
        end
        suc = 0;
        for jj=1:numel(pix0)
            [ih0,iw0] = ind2sub([H1,W1],pix0(jj));
            xr = datWarp(ih0,iw0,:);            
            ih0a = ih0+min(rgH1)-1;
            iw0a = iw0+min(rgW1)-1;
            tmp = lblMapS(ih0a,iw0a,:);
            tmp1 = tw1Vec(pix0(jj),:);
            %tmp1(1:max(round(dlyReg(ii)),1)) = 0;
            if sum(tmp1(tmp==0))>0
                suc = 1;
            end
            tmp(tmp==0) = tmp1(tmp==0)*nCnt;
            lblMapS(ih0a,iw0a,:) = tmp;
            dRecon(ih0a,iw0a,rgT) = max(dRecon(ih0a,iw0a,rgT),xr.^2);
        end
        if suc>0
            riseX(nCnt,1) = dlyReg(ii);
            riseXv(nCnt,1) = dlyRegV(ii);
            riseXn(nCnt,1) = dlyRegN(ii);
            nCnt = nCnt + 1;
        end
    end
end

end



