function [dat,opts] = prep1a(dat,opts)
    %PREP1A process data
    
    bdCrop = opts.regMaskGap;

    opts.filePath = [];
    opts.fileName = [];
    opts.fileType = [];
    
    % read data
    %maxDat = max(dat(:));
    %dat = dat/maxDat;
    dat = dat(bdCrop+1:end-bdCrop,bdCrop+1:end-bdCrop,:);
    dat(dat<0) = 0;
    if opts.usePG==1
        dat = sqrt(dat);
    end
    
    dat = dat + randn(size(dat))*1e-6;
    [H,W,T] = size(dat);
    opts.sz = [H,W,T];
    opts.maxValueDepth = 16;
    opts.maxValueDat = 65535;
    
end




