function [ vidDc, cBias, psfx ] = loadVideo(fName,scanType)
%LOADVIDEO Load calcium movie with optiional de-convolution

if ~exist('scanType','var')
    scanType = 'galvo';
end

fprintf('Reading...\n')

switch scanType
    case 'galvo'
        deconvMe = 0;
        cBias = 0.03;
    otherwise
        deconvMe = 1;
        cBias = 0.12;
end

if exist([fName,'_dc.tif'],'file')
    vid = io.readTiffSeq([fName,'_dc.tif'],1);
    deconvMe = 0;
else
    f1 = [fName,'.tif'];
    f2 = [fName,'.tiff'];
    if exist(f1,'file')
        vid = io.readTiffSeq(f1,1);
    else
        vid = io.readTiffSeq(f2,1);
    end
end

vid = vid/max(vid(:));
%corrMapAvg8 = glia.getCorrMapAvg8(vid);

% deconvolution
if deconvMe
    fprintf('De-convolution...\n')
    [ ~, psfx ] = glia.getPsf2nd1direction( vid );
    vidDc = glia.deConvScan(vid, psfx);
    %corrMapDcAvg8 = glia.getCorrMapAvg8(vidDc);
    
    fprintf('Saving to current folder...\n')
    io.writeTiffSeq( [fName,'_dc.tif'], vidDc )
else
    vidDc = vid;
end

end

