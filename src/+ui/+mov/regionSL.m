function regionSL(~,~,f,op,lbl)
    bd = getappdata(f,'bd');
    opts = getappdata(f,'opts');
    
    if strcmp(op,'save')
        if strcmp(lbl,'cell')
            definput = {'_Cell.mat'};
            selname = inputdlg('Type desired suffix for Region file:',...
                'Region file',[1 75],definput);

            selname = char(selname);
            if isempty(selname)
                selname = '_Cell.mat';
            end
        else
            definput = {'LandMark.mat'};
            selname = inputdlg('Type desired suffix for Region file:',...
                'Region file',[1 75],definput);

            selname = char(selname);
            if isempty(selname)
                selname = '_LandMark.mat';
            end
        end
        file0 = [opts.fileName,selname];
        clear definput selname

        %file0 = [opts.fileName,'_AQuA']; SP, 18.07.16
        selpath = uigetdir('.','Choose output folder');
        path0 = [selpath,filesep,file0];
        if ~isnumeric(selpath)
            if bd.isKey(lbl)
                bd0 = bd(lbl);
            else
                bd0 = [];
            end
            save(path0,'bd0');
        end
    else
       [file,path] = uigetfile('.mat','Choose Region file'); 
       if ~isnumeric([path,file])
           loadContent = load([path,file],'bd0');
           bd(lbl) = loadContent.bd0;
           setappdata(f,'bd',bd);
           ui.movStep(f,[],[],1);
       end
    end 
end