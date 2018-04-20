function [ref,tst,refBase,s,t,rgT1,spLst] = sp2graph(df0ip,vMap0,spLst,riseOnly,varEst)
% sp2graph convert super pixels to curves and graph nodes for GTW
% Input super pixels are not perfect:
% Empty or too small
% Bad corresponding curves

[H0,W0,T0] = size(df0ip);

% test and refererence curves
% optionally, ignore signals after arriving peak
df0ipSmo = imgaussfilt3(df0ip,[1 1 1]);

df0Vec = reshape(df0ip,[],T0);
df0VecSmo = reshape(df0ipSmo,[],T0);
refBase = nanmean(df0Vec(vMap0>0,:),1);
refBase = refBase - min(refBase);
refBaseX = refBase;
if riseOnly
    [xPeakBase,tPeakBase] = max(refBase);
    refBaseX(tPeakBase:end) = xPeakBase;
end

nSp = numel(spLst);
tst = zeros(nSp,T0);
ref = zeros(nSp,T0);
tPeak = zeros(nSp,1);
v00 = sqrt(varEst)/16;
for ii=1:numel(spLst)
    sp0 = spLst{ii};
    if numel(sp0)>2
        % scale and baseline
        tst0smo = nanmean(df0VecSmo(sp0,:),1);
        tst0smo = tst0smo - min(tst0smo);
        k0 = max(tst0smo)/max(refBaseX);
                               
        tst0 = nanmean(df0Vec(sp0,:),1);
        tst0g = imgaussfilt(tst0,1);        
        tst0 = tst0 - min(tst0g);
        
        if riseOnly>0
            [x,ix] = max(tst0smo); 
            xn = rand(1,numel(tst0)-ix+1)*v00;
            tst0(ix:end) = x+xn;
            tPeak(ii) = ix;
        end
        
        ref0 = refBaseX*k0;
        tst(ii,:) = tst0;
        ref(ii,:) = ref0;        
    end
end

% clip movie from beginning to the latest happen peak time
ta = 1;
if riseOnly>0
    tb = min(max(round(quantile(tPeak,0.99)),3),T0);
else
    tb = T0;
end
rgT1 = ta:tb;
refBase = refBaseX(ta:tb);
tst = tst(:,rgT1);
ref = ref(:,rgT1);

idxGood = var(tst,0,2)>1e-10;
spLst = spLst(idxGood);
tst = tst(idxGood,:);
ref = ref(idxGood,:);

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
    [ih0,iw0] = ind2sub([H0,W0],sp0);
    neib0 = [];
    for jj=1:numel(dh)
        ih = ih0+dh(jj);
        iw = iw0+dw(jj);
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



