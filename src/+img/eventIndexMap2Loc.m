function loc = eventIndexMap2Loc( evtIdxMap )
%EVENTINDEXMAP2LOC Transform event index map to locations

% fprintf('Converting index to location cells ...\n')

nEvt = max(evtIdxMap(:));
loc = cell(nEvt,1);
[H,W,T] = size(evtIdxMap);

for tt=1:T
    if mod(tt,1000)==0
        fprintf('t: %d\n',tt)
    end
    evtIdxMap_tt = evtIdxMap(:,:,tt);
    evtIdx_tt = unique(evtIdxMap_tt);
    evtIdx_tt = evtIdx_tt(evtIdx_tt>0);
    locBase = H*W*(tt-1);
    for ii=1:length(evtIdx_tt)
        evt0 = evtIdx_tt(ii);
        l0 = find(evtIdxMap_tt==evt0) + locBase;
        tmp = loc{evt0};
        if isempty(tmp)
            loc{evt0} = l0;
        else
            loc{evt0} = [tmp;l0];
        end
    end
end

end

