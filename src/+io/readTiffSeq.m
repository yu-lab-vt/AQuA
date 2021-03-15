function [img,maxVal] = readTiffSeq( fName, rescaleImg )
%READTIFF Read image sequence

if ~exist('rescaleImg','var')
    rescaleImg = 0;
end

info = imfinfo(fName);
maxVal = 2^info(1).BitDepth-1;
nFrames = numel(info);
oneFrame = imread(fName, 1);
% change
nRow = info(1).Height;
nCol = info(1).Width;
nChannel = info(1).SamplesPerPixel;
% [nRow,nCol] = size(oneFrame);
img = zeros(nRow, nCol, nFrames, 'single');
for k = 1:nFrames
    oneFrame = imread(fName, k);
    if(nChannel>1)
        oneFrame = mean(oneFrame,3);
    end
    if rescaleImg
        img(:,:,k) = single(oneFrame)/maxVal;
    else
        img(:,:,k) = oneFrame;
    end
end

end

