function writeTiffSeq( fName, dat, bitDepth, rescale )
%WRITEIFFSEQ Write image sequence

if ~exist('rescale','var')
    rescale = 0;
end
if ~exist('bitDepth','var')
    if length(size(dat))==3
        bitDepth = 16;
    else
        bitDepth = 8;
    end
end

if rescale
    dat = double(dat);
    dat = dat/max(dat(:));
end

if bitDepth>0
    if bitDepth==8
        dat = uint8(round(dat*255));
    end
    if bitDepth==16
        dat = uint16(round(dat*65535));
    end
end

if length(size(dat))==2
    imwrite(dat,fName);
end

if length(size(dat))==3    
    imwrite(dat(:,:,1),fName);
    for ii=2:size(dat,3)
        imwrite(dat(:,:,ii),fName,'writemode','append');
    end
end

if length(size(dat))==4
    imwrite(dat(:,:,:,1),fName);
    for ii=2:size(dat,4)
        imwrite(dat(:,:,:,ii),fName,'writemode','append');
    end    
end



end

