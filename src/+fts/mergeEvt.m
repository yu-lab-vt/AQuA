function mOut = mergeEvt(mIn,opts)
% mergeEvt merge spatially close events, for Glutamate or some noisy invivo data
% if events already adjacent, do not merge them
%
% TODO: use a distance measure using intensity to control merging

minDist = opts.mergeEventDiscon;

if minDist<=0
    mOut = mIn;
    return
end

se0 = ones(minDist,minDist);
evtLst = label2idx(mIn);

mDi = zeros(size(mIn),'uint32');
for tt=1:size(mIn,3)
    tmp = mIn(:,:,tt);
    mDi(:,:,tt) = imdilate(tmp>0,strel(se0));
end
% mDi = imdilate(mIn>0,strel(se0));
mL = bwlabeln(mDi);
mskLst = label2idx(mL);

mOut = zeros(size(mIn),'uint32');
nCnt = 1;
for ii=1:numel(mskLst)
    vox0 = mskLst{ii};
    idx = mIn(vox0);
    idx = idx(idx>0);
    idx = unique(idx);
    for jj=1:numel(idx)
        mOut(evtLst{idx(jj)}) = uint32(nCnt);
    end    
    nCnt = nCnt + 1;
end

end