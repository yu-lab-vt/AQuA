function [evtMem,evtMemC] = evtGrowLm1(spEvt,distMat,cDelay,~)

nSeed = max(spEvt);
nSp = numel(spEvt);

evtCan = nan(nSp,1);
evtDist = Inf(nSp,1);
evtMem = spEvt;

% init neighbors
for ii=1:nSeed
    idx = find(spEvt==ii,1); % !! each lm has one sp
    tmp = reshape(distMat(idx,:),[],1);
    neib0 = find(tmp>=0);
    neib0 = neib0(evtMem(neib0)==0);
    if ~isempty(neib0)  % keep smallest distance
        dist0 = reshape(tmp(neib0),[],1);
        distNow = evtDist(neib0);
        canNow = evtCan(neib0);
        canNow(dist0<distNow) = ii;
        distNow = min(dist0,distNow);
        evtCan(neib0) = canNow;
        evtDist(neib0) = distNow;
    end
end

% add one by one, small distance first
% some super pixels may not be reachable by seeds
while 1
    [x,ix] = min(evtDist);
    if isinf(x)
        break
    end
    evtMem(ix) = evtCan(ix);
    evtDist(ix) = inf;
    evtCan(ix) = nan;

    tmp = reshape(distMat(ix,:),[],1);
    neib0 = find(tmp>=0);
    neib0 = neib0(evtMem(neib0)==0);
    if ~isempty(neib0)  % keep smallest distance
        dist0 = tmp(neib0);
        distNow = evtDist(neib0);
        canNow = evtCan(neib0);
        canNow(dist0<distNow) = evtMem(ix);
        distNow = min(dist0,distNow);
        evtCan(neib0) = canNow;
        evtDist(neib0) = distNow;
    end  
    if 0
        plt.superPixelsSelected(spMap,evtMem);
        keyboard
        close
    end
end

% partition by continuity
A = Inf(nSeed,nSeed);
[ia,ib] = find(distMat>0);
for ii=1:numel(ia)
    ia0 = ia(ii);
    ib0 = ib(ii);
    evta = evtMem(ia0);
    evtb = evtMem(ib0);
    if evta>0 && evtb>0
        A(evta,evtb) = min(distMat(ia0,ib0),A(evta,evtb));
    end
end
A(A>cDelay) = Inf;

B = A;
B(A<inf) = 1;
B(isinf(A)) = 0;
B(eye(nSeed)>0) = 1;
B = max(B,B');

G = graph(B);
evtMemC = evtMem*0;
cc = conncomp(G,'OutputForm','cell');
for ii=1:numel(cc)
    cc0 = cc{ii};
    for jj=1:numel(cc0)
        evtMemC(evtMem==cc0(jj)) = ii;
    end
end

% plt.superPixelsSelected(spMap,evtMem);
% plt.superPixelsSelected(spMap,evtMemC);

end


