function saveOpt(~,~,f)
    
    opts = getappdata(f,'opts');
    % should update new changing
    fh = guidata(f);
    opts.thrARScl = str2double(fh.thrArScl.String);
    opts.smoXY = str2double(fh.smoXY.String);
    opts.minSize = str2double(fh.minSize.String);
    opts.thrTWScl = str2double(fh.thrTWScl.String);
    opts.thrExtZ = str2double(fh.thrExtZ.String);
    opts.cRise = str2double(fh.cRise.String);
    opts.cDelay = str2double(fh.cDelay.String);
    opts.gtwSmo = str2double(fh.gtwSmo.String);
    opts.zThr = str2double(fh.zThr.String);
    opts.ignoreMerge = fh.ignoreMerge.Value==1;
    opts.mergeEventDiscon = str2double(fh.mergeEventDiscon.String);
    opts.mergeEventCorr = str2double(fh.mergeEventCorr.String);
    opts.mergeEventMaxTimeDif = str2double(fh.mergeEventMaxTimeDif.String);
    opts.extendEvtRe = fh.extendEvtRe.Value==1;
    opts.ignoreTau = fh.ignoreTau.Value==1;
    
    % SP, 18.07.16
    definput = {'_Opt.csv'};
    selname = inputdlg('Type desired suffix for Parameter file name:',...
        'Parameter file',[1 75],definput);
    
    selname = char(selname);
    if isempty(selname)
        selname = '_Opt.csv';
    end
    file0 = [opts.fileName,selname];
    clear definput selname
    
    %file0 = [opts.fileName,'_AQuA']; SP, 18.07.16
    selpath = uigetdir(opts.filePath,'Choose output folder');
    path0 = [selpath,filesep];
    if ~isnumeric(selpath)
        ui.proj.struct2csv(opts,[path0,file0]);
    end
    
end