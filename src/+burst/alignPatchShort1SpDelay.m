function [lblMapS,dRecon,riseX] = alignPatchShort1SpDelay(...
    voxLst,resc,vmapc1,rgHc,rgWc,rgTc,rgTxc,tw1Vecc,spSz,H,W,T)

% super pixels delay
dRecon = zeros(H,W,T,'uint8');
lblMapS = zeros(H,W,T,'uint32');
riseX = nan(0,1);
riseXv = nan(0,1);
riseXn = nan(0,1);
nCnt = 1;
for nn=1:numel(voxLst)
    if mod(nn,1000)==0; fprintf('%d\n',nn); end
    res = resc{nn};
    if isempty(res)
        continue
    end
    datWarp = res.datWarp;
    dMapS = res.dMapS;
    
    validMap1 = vmapc1{nn};        
    rgT = rgTc{nn};
    rgH1 = rgHc{nn};
    rgW1 = rgWc{nn};
    rgTx = rgTxc{nn};
    tw1Vec = tw1Vecc{nn};
    
    [H1,W1] = size(validMap1);
    vIdx = zeros(H1,W1);
    vIdx(validMap1>0) = 1:sum(validMap1(:)>0);
        
    % super pixel delay
    if sum(validMap1(:))<2*spSz
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
    dlyReg = res.tEvtUp - dlyReg + min(rgT) - 1 + min(rgTx) - 1;
    
    % gather results
    pixLst = label2idx(L);
    for ii=1:numel(pixLst)
        pix0 = pixLst{ii};
        if numel(pix0)<4
            continue
        end
        suc = 0;
        dlyRegxx = nan(numel(pix0),1);
        for jj=1:numel(pix0)
            [ih0,iw0] = ind2sub([H1,W1],pix0(jj));
            ih0a = ih0+min(rgH1)-1;
            iw0a = iw0+min(rgW1)-1;
            tmp = lblMapS(ih0a,iw0a,rgTx);
            tmp1 = tw1Vec(vIdx(pix0(jj)),:);
            if sum(tmp1(tmp==0))>0
                suc = 1;
            end
            tmp(tmp==0) = tmp1(tmp==0)*nCnt;
            tmp1(tmp>0) = 0;
            t00 = find(tmp1>0,1);
            if ~isempty(t00)
                dlyRegxx(jj) = t00+min(rgTx)-1;
            else
                dlyRegxx(jj) = nan;
            end
            lblMapS(ih0a,iw0a,rgTx) = uint32(tmp);
            xr = datWarp(ih0,iw0,:);
            dRecon(ih0a,iw0a,rgT+min(rgTx)-1) = max(dRecon(ih0a,iw0a,rgT+min(rgTx)-1),uint8(xr.^2*255));
        end
        if suc>0
            t01 = nanmean(dlyRegxx);
            if isnan(t01)
                t01 = min(rgTx);
            end
            %riseX(nCnt,1) = t01;
            riseX(nCnt,1) = dlyReg(ii);
            riseXv(nCnt,1) = dlyRegV(ii);
            riseXn(nCnt,1) = dlyRegN(ii);
            nCnt = nCnt + 1;
        end
    end
end

end


