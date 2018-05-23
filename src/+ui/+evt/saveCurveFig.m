function saveCurveFig(~,~,f)

    [file0,path0] = uiputfile('*.fig','Save curves as fig file');
    
    if ~isnumeric(file0)
        fh = guidata(f);
        axNow = fh.curve;
        f00 = figure();
        copyobj(axNow, f00);
        
        axNow = findobj(f00,'Tag','curve');
        f00.Position(3:4) = axNow.Position(3:4);
        
        savefig(f00, [path0,filesep,file0]);
        delete(f00);
    end
    
end