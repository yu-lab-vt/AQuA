function mOut = filterEvt(mIn,opts)

minSz = opts.minSize;
[H,W,~] = size(mIn);
evtLst = label2idx(mIn);
mOut = zeros(size(mIn),'uint32');
nn = 1;
for ii=1:numel(evtLst)
    evt0 = evtLst{ii};
    if ~isempty(evt0)
        [ih,iw,~] = ind2sub(size(mIn),evt0);
        ihw = sub2ind([H,W],ih,iw);
        ihwx = unique(ihw);
        if numel(ihwx)>minSz
            mOut(evt0) = uint32(nn);
            nn = nn + 1;
        end
    end   
end

end