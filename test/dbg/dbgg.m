nEvt = numel(res.fts.basic.area);
for ii=1:nEvt
    T0 = size(res.fts.propagation.areaFrame{ii},1);
    T1 = size(res.fts.region.landmarkDist.distPerFrame{ii},1);
    if T0~=T1
        fprintf('%d\n',ii)
    end
end

%%
for ii=1:numel(d2lmk)
    xxx = d2lmk{ii};
    if max(xxx(:))>50
        max(xxx(:))
    end
end