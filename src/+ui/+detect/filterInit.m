function filterInit(~,~,f)
    % filterInit initialize filtering table
    
    fh = guidata(f);
    fts = getappdata(f,'fts'); %#ok<NASGU>
    tb = fh.filterTable;
    
    fName = {'Area (um^2)',...
        'dF/F', ...
        'Duration (s)',...
        'P value (dffMax)',...
        'Decay Tau'};
    
    fCmd = {'fts.basic.area',...  % new feature name
        'fts.curve.dffMax',...
        'fts.curve.duration',...
        'fts.curve.dffMaxPval',...
        'fts.curve.decayTau'};
    
    T = cell(numel(fCmd),4);
    for ii=1:numel(fName)
        T{ii,1} = false;
        T{ii,2} = fName{ii};
        cmd0 = ['x=',fCmd{ii},';'];
        try
            eval(cmd0);
            T{ii,3} = nanmin(x);
            T{ii,4} = nanmax(x);
        catch
            fprintf('Feature misseed\n')
            T{ii,3} = NaN;
            T{ii,4} = NaN;
        end
    end
    
    tb.Data = T;
    tb.ColumnName = {'','Feature','Min','Max'};
    tb.ColumnWidth = {20 100 60 60};
    tb.ColumnEditable = [true,false,true,true];
    
    btSt = getappdata(f,'btSt');
    btSt.ftsCmd = fCmd;
    setappdata(f,'btSt',btSt);
    
end

