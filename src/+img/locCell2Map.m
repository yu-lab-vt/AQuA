function crIdx = locCell2Map(locAR,sz,showMe)

crIdx = zeros(sz);
for ii=1:length(locAR)
    pix0 = locAR{ii};
    if ~isempty(pix0)
        crIdx(locAR{ii}) = ii;
    end
end

if showMe>0
    zzshow(crIdx);
end

end