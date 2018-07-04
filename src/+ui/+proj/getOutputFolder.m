function getOutputFolder(~,~,f)
    
    opts = getappdata(f,'opts');
    file0 = [opts.fileName,'_aqua'];
    selpath = uigetdir('.','Choose output folder');
    path0 = [selpath,filesep,opts.fileName];
    if ~isnumeric(selpath)
        ui.proj.saveExp([],[],f,file0,path0);
    end
    
end