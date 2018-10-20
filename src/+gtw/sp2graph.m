function [ref,tst,refBase,s,t,idxGood] = sp2graph(df0ip,vMap0,spLst,seedIn,gapSeedHW)
% sp2graph convert super pixels to curves and graph nodes for GTW
% Input super pixels are not perfect:
% Empty or too small
% Bad corresponding curves

[H0,W0,T0] = size(df0ip);

% test and refererence curves
% optionally, ignore signals after arriving peak
% FIXME do we need to smooth raw data?
% df0ipSmo = imgaussfilt3(df0ip,[1 1 1]);
% df0ipSmo = imgaussfilt3(df0ip,[0.1 0.1 0.1]);
df0ipSmo = df0ip;

% [ih,iw] = ind2sub([H0,W0],seedIn);

dt0 = bwdist(vMap0==0);
[~,ihw] = max(dt0(:));
[ih,iw] = ind2sub(size(vMap0),ihw);

rgh = max(ih-gapSeedHW,1):min(ih+gapSeedHW,H0);
rgw = max(iw-gapSeedHW,1):min(iw+gapSeedHW,W0);
df00Vec = reshape(df0ip(rgh,rgw,:),[],T0);
vm00 = vMap0(rgh,rgw);
df00Vec = df00Vec(vm00>0,:);
refBase = nanmean(df00Vec,1);
% refBase = imgaussfilt(refBase,1);  % FIXME how should we denoise ref curve?
refBase = refBase - nanmin(refBase);

r1 = refBase;
[~,ix] = max(r1);
bw = r1*0;
bw(ix) = 1;
r2 = -imimposemin(-r1,bw);
r2(ix) = r1(ix);
r2(isinf(r2)) = nan;
refBase = r2;

df0Vec = reshape(df0ip,[],T0);
df0VecSmo = reshape(df0ipSmo,[],T0);

nSp = numel(spLst);
tst = zeros(nSp,T0);
ref = zeros(nSp,T0);
for ii=1:numel(spLst)
    sp0 = spLst{ii};
    %     if numel(sp0)>2
    % scale and baseline
    tst0smo = nanmean(df0VecSmo(sp0,:),1);
    tst0smo = tst0smo - min(tst0smo);
    k0 = max(tst0smo)/max(refBase);
    
    tst0 = nanmean(df0Vec(sp0,:),1);
    tst0g = imgaussfilt(tst0,1);
    tst0 = tst0 - min(tst0g);
    
    ref0 = refBase*k0;
    tst(ii,:) = tst0;
    ref(ii,:) = ref0;
    %     end
end

idxGood = var(tst,0,2)>1e-10;
spLst = spLst(idxGood);
tst = tst(idxGood,:);
ref = ref(idxGood,:);

% graph, at most one pair between two nodes
s = nan(nSp,1);
t = nan(nSp,1);
nPair = 0;
% dh = [-1 0 1 -1 1 -1 0 1];
% dw = [-1 -1 -1 0 0 1 1 1];
dh = [0 -1 1 0];
dw = [-1 0 0 1];
spMap1 = zeros(H0,W0);

for ii=1:numel(spLst)
    spMap1(spLst{ii}) = ii;
end

for ii=1:numel(spLst)
    sp0 = spLst{ii};
    [ih0,iw0] = ind2sub([H0,W0],sp0);
    neib0 = [];
    for jj=1:numel(dh)  % find neighbors in eight directions
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



