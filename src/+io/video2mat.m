function XData = video2mat( fname )
%VIDEO2MAT read grayscale video and convert to Matlab array
% freemanwyz

xyloObj = VideoReader(fname);
vidWidth = xyloObj.Width;
vidHeight = xyloObj.Height;
vidLen = xyloObj.Duration*xyloObj.FrameRate;

XData = zeros(vidHeight,vidWidth,vidLen,'uint8');
for kk = 1:vidLen
    fprintf('%d\n',kk);
    XData(:,:,kk) = rgb2gray(readFrame(xyloObj));
end

end

