function evtLstOut = mergeEvt(evtLst,dffMat,tBegin,opts,bd)
    % mergeEvt merge spatially close events, for Glutamate or some noisy invivo data
    % if events already adjacent, do not merge them
    
    fprintf('Merging...\n')
    
    sz = opts.sz;
    ignoreMerge = opts.ignoreMerge;
    minDist = opts.mergeEventDiscon;
    minCorr = opts.mergeEventCorr;
    maxTimeDif = opts.mergeEventMaxTimeDif;
    
    mIn = zeros(sz,'uint32');
    evtCellLabel = zeros(numel(evtLst),1);
    
    if ~isempty(bd) && bd.isKey('cell')
        bd0 = bd('cell');
        bdMap = zeros(sz(1)*sz(2),1);
        for ii=1:numel(bd0)
            p0 = bd0{ii}{2};
            bdMap(p0) = ii;     
        end
        bdMap = reshape(bdMap,sz(1:2));
%         evtCell{ii} = burst.mergeInCell(mIn0,dffMat,tBegin,minCorr,maxTimeDif);
    else
%         evtCell{1} = burst.mergeInCell(mIn,dffMat,tBegin,minCorr,maxTimeDif);
        bdMap = ones(sz(1:2));
    end
    
    for ii=1:numel(evtLst)
        mIn(evtLst{ii}) = ii;
        [ih,iw,it] = ind2sub(sz,evtLst{ii}(1));
        evtCellLabel(ii) = bdMap(ih,iw);
    end
    
    % do not need to merge
    if ignoreMerge>0
        evtLstOut = evtLst;
        return
    end
    
    
    bd0 = label2idx(bdMap);
    % dilate events
    se0 = ones(minDist*2+1,minDist*2+1);
    for tt=1:size(mIn,3)
        tmp = mIn(:,:,tt);
        for i = 1:numel(bd0)
           tmp0 = zeros(size(tmp)); 
           tmp0(bd0{i}) = tmp(bd0{i});
           tmp0 = imdilate(tmp0,strel(se0));
           tmp(bd0{i}) = tmp0(bd0{i});
        end
        mIn(:,:,tt) = tmp;
    end  
    
    
    
    % neighbor graphs
    G = burst.evtNeibCorr(mIn,dffMat,tBegin,minCorr,maxTimeDif);
    
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












