function zVec = getSpZ(dat,lblMapS,varEst)
% significance of each super voxel
% minimum of paired z-test scores
% better to use order-statistics

s0 = sqrt(varEst);
[H,W,T] = size(dat);
datVec = reshape(dat,[],T); clear dat;
spLst = label2idx(lblMapS);
lblMapSVec = reshape(lblMapS,[],T); clear lblMapS;
zVec = nan(numel(spLst),1);

for nn=1:numel(spLst)
    sp0 = spLst{nn};
    if isempty(sp0)
        continue
    end
    [ih,iw,it] = ind2sub([H,W,T],sp0);
    ihw = sub2ind([H,W],ih,iw);
    ihw = unique(ihw);
    T0 = max(min(it)-2,1);
    T1 = min(max(it)+2,T);
    
    x = datVec(ihw,T0:T1);
    m = lblMapSVec(ihw,T0:T1);
    x(m>0 & m~=nn) = nan;
    xm = nanmean(x,1);
    
    [~,tPeak] = max(xm);
    [~,t0] = min(xm(1:tPeak));
    [~,t1p] = min(xm(tPeak:end));
    t1 = tPeak+t1p-1;
    
    s00 = s0/sqrt(numel(ihw));
    zVec(nn) = min(nanmean(x(:,tPeak)-x(:,t0))/s00,nanmean(x(:,tPeak)-x(:,t1))/s00);
end

end