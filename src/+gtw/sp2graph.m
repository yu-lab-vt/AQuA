function [ref,tst,refBase,s,t] = sp2graph(df0ip,vMap0,spLst,varEst)
% sp2graph convert super pixels to curves and graph nodes for GTW

[H0,W0,T0] = size(df0ip);

% test and refererence curves
% ignore signals after arriving peak
df0ipSmo = imgaussfilt3(df0ip,[1 1 1]);

df0Vec = reshape(df0ip,[],T0);
df0VecSmo = reshape(df0ipSmo,[],T0);
refBase = nanmean(df0Vec(vMap0>0,:),1);
refBase = refBase - min(refBase);
[xPeakBase,tPeakBase] = max(refBase);
refBaseX = refBase;
refBaseX(tPeakBase:end) = xPeakBase;

nSp = numel(spLst);
tst = zeros(nSp,T0);
ref = zeros(nSp,T0);
tPeak = zeros(nSp,1);
v00 = sqrt(varEst)/16;
for ii=1:numel(spLst)
    sp0 = spLst{ii};
    if ~isempty(sp0)
        % scale and baseline
        tst0smo = nanmean(df0VecSmo(sp0,:),1);
        tst0smo = tst0smo - min(tst0smo);
        k0 = max(tst0smo)/max(refBaseX);
        [x,ix] = max(tst0smo);                
        
        tst0 = nanmean(df0Vec(sp0,:),1);
        tst0g = imgaussfilt(tst0,1);        
        tst0 = tst0 - min(tst0g);
        xn = rand(1,numel(tst0)-ix+1)*v00;
        tst0(ix:end) = x+xn;
        
        ref0 = refBaseX*k0;
        tst(ii,:) = tst0;
        ref(ii,:) = ref0;
        tPeak(ii) = ix;
    end
end

ta = 1;
tb = round(quantile(tPeak,0.99));
% T1 = tb-ta+1;
refBase = refBaseX(ta:tb);
tst = tst(:,ta:tb);
ref = ref(:,ta:tb);

% idx = L(413,294);
% idx = L(419,285);
% idx = L(409,285);
% figure;plot(ref(idx,:));hold on;plot(tst(idx,:));

% graph, at most one pair between two nodes
s = nan(nSp,1);
t = nan(nSp,1);
nPair = 0;
dh = [-1 0 1 -1 1 -1 0 1];
dw = [-1 -1 -1 0 0 1 1 1];
spMap1 = zeros(H0,W0);
for ii=1:numel(spLst)
    spMap1(spLst{ii}) = ii;
end
for ii=1:numel(spLst)
    sp0 = spLst{ii};
    [ih,iw] = ind2sub([H0,W0],sp0);
    neib0 = [];
    for jj=1:numel(dh)
        ih = ih+dh(jj);
        iw = iw+dw(jj);
        idxOK = ih>0 & ih<=H0 & iw>0 & iw<=W0;
        ih = ih(idxOK);
        iw = iw(idxOK);
        ihw = sub2ind([H0,W0],ih,iw);
        if ~isempty(ihw)
            newMap = spMap1(ihw);
            newMap = unique(newMap(newMap>ii));
            newMap = setdiff(newMap,neib0);
            neib0 = union(newMap,neib0);
            for kk=1:numel(newMap)
                nPair = nPair+1;
                s(nPair) = ii;
                t(nPair) = newMap(kk);
            end
        end
    end
end
s = s(~isnan(s));
t = t(~isnan(t));

end



