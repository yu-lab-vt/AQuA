function validIdxMap = getValidIdxMap( validMap, plotMe )
%GETVALIDIDXMAP Compute index of valid pixels

if ~exist('plotMe','var')
    plotMe = 0;
end

validIdxMap = validMap*1;
validIdxMap(validMap>0) = 1:sum(validMap(:)>0);

if plotMe
    figure;imshow(validIdxMap)
end


end

