function [spC,rtC,rgC] = sp2EvtTop(spMap,spRise)
% sp2EvtTop group super pixels to events

% gather data
[H,W,T] = size(spMap);

cc = bwconncomp(spMap);
nCC = cc.NumObjects;
rtC = cell(nCC,1);
spC = cell(nCC,1);
rgC = cell(nCC,3);
for ii=1:nCC
    if mod(ii,1000)==0; fprintf('%d\n',ii); end
    
    pix0 = cc.PixelIdxList{ii};
    [ih,iw,it] = ind2sub([H,W,T],pix0);
    rgH = min(ih):max(ih);
    rgW = min(iw):max(iw);
    rgT = min(it):max(it);
    rgC(ii,:) = {rgH,rgW,rgT};
    ih1 = ih - min(rgH) + 1;
    iw1 = iw - min(rgW) + 1;
    it1 = it - min(rgT) + 1;
    
    % remove super pixels outside this connected component
    pix1 = sub2ind([numel(rgH),numel(rgW),numel(rgT)],ih1,iw1,it1);
    msk0 = zeros(numel(rgH),numel(rgW),numel(rgT));    
    msk0(pix1) = 1;
    spMap0 = spMap(rgH,rgW,rgT).*msk0;
    
    % delay
    x = spMap0(spMap0>0);
    x = sort(unique(x),'ascend');
    t = spRise(x);
    
    % shift the index
    spMap0 = spMap0 - min(x) + 1;
    x = x - min(x) + 1;
    
    % re-code the index
    cc1 = label2idx(spMap0);
    spMap0t = zeros(size(spMap0));
    for jj=1:numel(cc1)
        cc11 = cc1{jj};
        if ~isempty(cc11)
            x0 = unique(spMap0(cc1{jj}));
            idx = find(x==x0,1);
            spMap0t(cc1{jj}) = idx;
        end
    end
    spC{ii} = spMap0t;
    rtC{ii} = t;
end

end











