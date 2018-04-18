function lblMapC = sp2EvtTopStep2(spC,rtC,rgC,cRise,cDelay,cOver,H,W,T)
% sp2EvtTop group super pixels to events

% find events
resC = cell(numel(rtC),1);
% [x,ix] = max(cellfun(@numel,rtC));
% for ii=6
parfor ii=1:numel(rtC)
    fprintf('%d\n',ii);
    sp0 = spC{ii};
    rt0 = rtC{ii};
    resC{ii} = burst.sp2EvtTreeFast(sp0,rt0,cRise,cDelay,cOver);
    %resC{ii} = burst.sp2EvtTree(sp0,rt0,cRise,cDelay,cOver);
end

% put back to movie
lblMapC = zeros(H,W,T);
nEvt = 0;
for ii=1:numel(rtC)
    rgH = rgC{ii,1};
    rgW = rgC{ii,2};
    rgT = rgC{ii,3};
    c0 = resC{ii};
    if isempty(c0)
        continue
    end
    nEvt0 = max(c0(:));
    c0(c0>0) = c0(c0>0) + nEvt;
    lblMapC(rgH,rgW,rgT) = max(lblMapC(rgH,rgW,rgT),c0);
    nEvt = nEvt + nEvt0;
end

% L = double(labelmatrix(cc));
% ov0 = plt.regionMapWithData(L,zeros(size(L)),2); zzshow(ov0);

end











