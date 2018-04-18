function distMat = distSp(lblMapS,riseMap,maxRiseDly)
% distance between neighboring super pixels
% neighbors and conflicts
[H,W,T] = size(lblMapS);
dh = [-1 0 1 -1 1 -1 0 1];
dw = [-1 -1 -1 0 0 1 1 1];
spVoxLst = label2idx(lblMapS);
nSp = numel(spVoxLst);
distMat = nan(nSp,nSp);
for nn=1:nSp
    vox0 = spVoxLst{nn};
    [ih,iw,it] = ind2sub([H,W,T],vox0);
    for ii=1:numel(dh)
        ih1 = min(max(ih + dh(ii),1),H);
        iw1 = min(max(iw + dw(ii),1),W);
        vox1 = sub2ind([H,W,T],ih1,iw1,it);
        x = lblMapS(vox1);
        idxSel = find(x>0 & x~=nn);
        if ~isempty(idxSel)
            vox1Sel = vox1(idxSel);
            vox0Sel = vox0(idxSel);
            
            % delay difference in boundary pixels
            rise0 = riseMap(vox0Sel);
            rise1 = riseMap(vox1Sel);
            riseDif = abs(rise0-rise1);
            
            xSel = x(idxSel);
            xGood = xSel(riseDif<maxRiseDly);
            riseDifGood = riseDif(riseDif<maxRiseDly);
            x = unique(xGood);
            for kk=1:numel(x)
                tMin = min(riseDifGood(xGood==x(kk)));
                distMat(nn,x(kk)) = tMin;
                distMat(x(kk),nn) = tMin;
            end
        end
    end
end
end

