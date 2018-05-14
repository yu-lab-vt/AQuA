function evtLstOut = mergeEvt(evtLst,dffMat,tBegin,opts)
    % mergeEvt merge spatially close events, for Glutamate or some noisy invivo data
    % if events already adjacent, do not merge them
    
    fprintf('Merging...\n')
    
    sz = opts.sz;
    minDist = opts.mergeEventDiscon;
    minCorr = opts.mergeEventCorr;
    maxTimeDif = opts.mergeEventMaxTimeDif;
    
    mIn = zeros(sz,'uint32');
    for ii=1:numel(evtLst)
        mIn(evtLst{ii}) = ii;
    end
    
    % do not need to merge
    if minDist<=0
        evtLstOut = evtLst;
        return
    end
    
    % dilate events
    se0 = ones(minDist,minDist);
    for tt=1:size(mIn,3)
        tmp = mIn(:,:,tt);
        mIn(:,:,tt) = imdilate(tmp,strel(se0));
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












