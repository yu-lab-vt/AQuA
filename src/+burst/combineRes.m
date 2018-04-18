function [lblMapE,dRecon] = combineRes(lblMapC,dlyOrder,mskLst,resLst,vLst,iLst,H,W,T)
nCnt = 1;
lblMapE = zeros(H,W,T,'uint32');
dRecon = zeros(H,W,T,'uint8');
nEvt = numel(resLst);
rThr = 0;
k = 1/(1-rThr)^2;
for nn=1:nEvt
    if mod(nn,100)==0; fprintf('%d/%d\n',nn,nEvt); end
    res = resLst{nn};
    if isempty(res)
        continue
    end
    
    datWarp = res.datWarp;
    validMap2 = vLst{nn};
    [H1,W1] = size(validMap2);
    rgH1 = iLst{nn,1};
    rgW1 = iLst{nn,2};
    rgT = iLst{nn,3};
    pix0 = find(validMap2>0);
    datWarp(mskLst{nn}) = 0;  % !!
    for jj=1:numel(pix0)
        [ih0,iw0] = ind2sub([H1,W1],pix0(jj));
        xr = datWarp(ih0,iw0,:);
        xSig = zeros(T,1);
        xSig(rgT) = xr>rThr;  % has bright enough signal
        
        ih0a = ih0+min(rgH1)-1;
        iw0a = iw0+min(rgW1)-1;
        xCur = squeeze(lblMapE(ih0a,iw0a,:));  % do not have another event
        lCur = squeeze(lblMapC(ih0a,iw0a,:));
        xx = dlyOrder(nn);
        lCur(lCur==xx) = 0;
        
        xNew = nCnt*(xCur==0 & xSig>0 & lCur==0);
        lblMapE(ih0a,iw0a,:) = uint32(xCur) + uint32(xNew);
        dRecon(ih0a,iw0a,rgT) = max(dRecon(ih0a,iw0a,rgT),uint8((xr-rThr).^2*k*255));
    end
    nCnt = nCnt + 1;
end
