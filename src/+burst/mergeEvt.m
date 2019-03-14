function evtLstOut = mergeEvt(evtLst,dffMat,tBegin,opts,f)
    % mergeEvt merge spatially close events, for Glutamate or some noisy invivo data
    % if events already adjacent, do not merge them
    
    fprintf('Merging...\n')
    
    sz = opts.sz;
    ignoreMerge = opts.ignoreMerge;
    minDist = opts.mergeEventDiscon;
    minCorr = opts.mergeEventCorr;
    maxTimeDif = opts.mergeEventMaxTimeDif;
    bd = getappdata(f,'bd');
    mIn = zeros(sz,'uint32');
    evtCellLabel = zeros(numel(evtLst),1);
    
    if bd.isKey('cell')
        bd0 = bd('cell');
        bdMap = zeros(sz(1)*sz(2),sz(3));
        for ii=1:numel(bd0)
            p0 = bd0{ii}{2};
            bdMap(p0,:) = ii;     
        end
        bdMap = reshape(bdMap,sz);
%         evtCell{ii} = burst.mergeInCell(mIn0,dffMat,tBegin,minCorr,maxTimeDif);
    else
%         evtCell{1} = burst.mergeInCell(mIn,dffMat,tBegin,minCorr,maxTimeDif);
        bdMap = ones(sz);
    end
    
    for ii=1:numel(evtLst)
        mIn(evtLst{ii}) = ii;
        [ih,iw,it] = ind2sub(sz,evtLst{ii}(1));
        evtCellLabel(ii) = bdMap(ih,iw,it);
    end
    
    % do not need to merge
    if ignoreMerge>0
        evtLstOut = evtLst;
        return
    end
    
    % dilate events
    se0 = ones(minDist*2+1,minDist*2+1);
    for tt=1:size(mIn,3)
        tmp = mIn(:,:,tt);
        mIn(:,:,tt) = imdilate(tmp,strel(se0));
    end  
    
    
    
    % neighbor graphs
    G = burst.evtNeibCorr(mIn,dffMat,tBegin,minCorr,maxTimeDif,bdMap,evtCellLabel);
    
    % connect events
    cc = conncomp(G,'OutputForm','cell');
    evtLstOut = cell(numel(cc),1);
    for ii=1:numel(cc)
        m0 = cc{ii};
        tmp = [];
        for jj=1:numel(m0)
            tmp = union(tmp,evtLst{m0(jj)});
        end  
        evtLstOut{ii} = tmp;
    end    
    
end












