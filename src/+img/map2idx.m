function validIdxMap = map2idx( validMap, drawNow )
%MAP2IDX Summary of this function goes here
%   Detailed explanation goes here

if ~exist('drawNow','var')
    drawNow = 1;
end

validIdxMap = validMap;
validIdxMap(validMap>0) = 1:sum(validMap(:)>0);

if drawNow
    figure;imshow(validIdxMap)
end

end

