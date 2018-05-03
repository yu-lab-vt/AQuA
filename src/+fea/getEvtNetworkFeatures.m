function res = getEvtNetworkFeatures(evts,sz)
% getEvtNetworkFeatures get network work level features for each event
% Not include evnet level features like size and brightness
% Pre-filter with bounding box overlapping

H = sz(1); W = sz(2); T = sz(3);

nEvt = numel(evts);
ex = zeros(nEvt,6);
evtSize = zeros(nEvt,1);
idxBad = true(nEvt,1);
tIdx = cell(T,1);
for nn=1:nEvt
    pix0 = evts{nn};
    if ~isempty(pix0)
        idxBad(nn) = false;
        [ih,iw,it] = ind2sub([H,W,T],pix0);
        ihw = sub2ind([H,W],ih,iw);
        ihw = unique(ihw);
        evtSize(nn) = numel(ihw);
        ex(nn,:) = [min(ih),max(ih),min(iw),max(iw),min(it),max(it)];
        for tt=min(it):max(it)
            tIdx{tt} = union(tIdx{tt},nn);
        end
    end
end
tLen = cellfun(@numel,tIdx);
regSel = ones(nEvt,1);
regSel(idxBad) = 0;

% all events and events with similar size
nOccurSameLoc = nan(nEvt,2);
nOccurSameTime = nan(nEvt,1);
occurSameLocList = cell(nEvt,2);
occurSameTimeList = cell(nEvt,1);
for ii=1:nEvt
    if mod(ii,1000)==0
        fprintf('%d\n',ii);
    end    
    if regSel(ii)==0
        continue
    end
    p0 = ex(ii,:);
    h0 = p0(1); h1 = p0(2);
    w0 = p0(3); w1 = p0(4);
    t0 = p0(5); t1 = p0(6);
    
    % occur at same spatial location
    isSel = h0<=ex(:,2) & h1>=ex(:,1) & w0<=ex(:,4) & w1>=ex(:,3);
    %isSel(ii) = 0;
    if sum(isSel)>0
        szCo = evtSize(isSel);
        szMe = evtSize(ii);
        idxSel = find(isSel);        
        isSelSimilarSize = szMe./szCo<2 & szMe./szCo>1/2;
        nOccurSameLoc(ii,1) = sum(1*isSel);
        nOccurSameLoc(ii,2) = sum(1*isSelSimilarSize);        
        occurSameLocList{ii,1} = idxSel;
        occurSameLocList{ii,2} = idxSel(isSelSimilarSize);        
    end
    
    % occur at same time
    tLen0 = tLen(t0:t1);
    tIdx0 = tIdx(t0:t1);
    [x,ix] = max(tLen0);
    tIdx0 = tIdx0{ix};
    nOccurSameTime(ii) = x;
    occurSameTimeList{ii} = tIdx0;
end

% output ----
res = [];
res.nOccurSameLoc = nOccurSameLoc;
res.nOccurSameTime = nOccurSameTime;
res.occurSameLocList = occurSameLocList;
res.occurSameTimeList = occurSameTimeList;

end


















