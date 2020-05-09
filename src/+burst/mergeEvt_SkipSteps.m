function evtLstOut = mergeEvt_SkipSteps(evtLst,opts,bd)

    sz = opts.sz;
    labelMap = zeros(sz);
    for i = 1:numel(evtLst)
        labelMap(evtLst{i}) = i;
    end
    
    %% boundary
    if exist('bd')==1 && ~isempty(bd) && bd.isKey('cell')
        bd0 = bd('cell');
        bdMap = zeros(sz(1)*sz(2),1);
        for ii=1:numel(bd0)
            p0 = bd0{ii}{2};
            bdMap(p0) = ii;     
        end
        bdMap = reshape(bdMap,sz(1:2));
    else
        bdMap = ones(sz(1:2));
    end
    bdPix = find(bdMap)>0;
    
    %% dilate
    se0 = ones(opts.mergeEventDiscon*2+1,opts.mergeEventDiscon*2+1,opts.mergeEventMaxTimeDif*2+1);
    dilation = imdilate(labelMap>0,strel(se0));
    dilation = reshape(dilation,[],sz(3));
    dilation(~bdPix,:) = 0;
    dilation = reshape(dilation,sz);
    
    %% connected
    cc = bwconncomp(dilation);
    cc = cc.PixelIdxList;
    evtLstOut = cell(numel(cc),1);
    for k = 1:numel(cc)
       labels = setdiff(unique(labelMap(cc{k})),0);
       for i = 1:numel(labels)
          curLabel = labels(i);
          evtLstOut{k} = [evtLstOut{k};evtLst{curLabel}];
       end
    end
end












