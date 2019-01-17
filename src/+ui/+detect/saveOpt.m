function saveOpt(~,~,f)
    
    opts = getappdata(f,'opts');
    
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
    selpath = uigetdir('.','Choose output folder');
    path0 = [selpath,filesep];
    if ~isnumeric(selpath)
        ui.proj.struct2csv(opts,[path0,file0]);
    end
    
end