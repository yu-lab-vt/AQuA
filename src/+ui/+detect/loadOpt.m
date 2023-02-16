function loadOpt(~,~,f)
    
    %file0 = [opts.fileName,'_AQuA']; SP, 18.07.16
    opts = getappdata(f,'opts');
    [file,path] = uigetfile('.csv','Choose Parameter file',opts.filePath);
    if ~isnumeric([path,file])
        optsOrg = getappdata(f,'opts');
        opts = ui.proj.csv2struct([path,file]);
        opts.filePath = optsOrg.filePath;
        opts.fileName = optsOrg.fileName;
        opts.fileNameType = optsOrg.fileType;
        opts.sz = optsOrg.sz;
        opts.maxValueDat = optsOrg.maxValueDat;
        opts.maxValueDepth = optsOrg.maxValueDepth;
        opts.frameRate = optsOrg.frameRate;
        opts.spatialRes = optsOrg.spatialRes;
        setappdata(f,'opts',opts);
        
        % adjust interface parameters
        fh = guidata(f);
        fh.thrArScl.String = num2str(opts.thrARScl);
        fh.smoXY.String = num2str(opts.smoXY);
        fh.minSize.String = num2str(opts.minSize);
        fh.thrTWScl.String = num2str(opts.thrTWScl);
        fh.thrExtZ.String = num2str(opts.thrExtZ);
        fh.cRise.String = num2str(opts.cRise);
        fh.cDelay.String = num2str(opts.cDelay);
        fh.gtwSmo.String = num2str(opts.gtwSmo);
        fh.zThr.String = num2str(opts.zThr);
        fh.ignoreMerge.Value = opts.ignoreMerge;
        fh.mergeEventDiscon.String = num2str(opts.mergeEventDiscon);
        fh.mergeEventCorr.String = num2str(opts.mergeEventCorr);
        fh.mergeEventMaxTimeDif.String = num2str(opts.mergeEventMaxTimeDif);
        fh.extendEvtRe.Value = opts.extendEvtRe;
        fh.ignoreTau.Value = opts.ignoreTau;
        
        n = fh.sldMov.Value;
        ui.mov.updtMovInfo(f,n,opts.sz(3));
    end
end
