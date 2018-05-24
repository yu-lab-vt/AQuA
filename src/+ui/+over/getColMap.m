function getColMap(~,~,f)
   
    tb = readtable('./cfg/userColors.csv','Delimiter',',','ReadVariableNames',0,'ReadRowNames',1);         
    colNames = tb.Properties.RowNames;
    
    % colorbrew
    nCol = numel(colNames);
    colVals = cell(nCol,1);
    for ii=1:nCol
        v0 = tb{ii,1:end};
        idxGood = ~cellfun(@isempty,v0);
        nGood = sum(idxGood);
        if nGood>1
            val0 = nan(nGood,3);
            for jj=1:nGood
                val0(jj,:) = eval(['[',v0{jj},']']);
            end
            colVals{ii} = val0;
        else % search in colorbrew
            c0 = colNames{ii};
            try
                colVals{ii} = brewermap(50,c0);
            catch
                msgbox('Invalid brewer color scheme name')
            end
        end
    end
    
    fh = guidata(f);
    fh.overlayColor.String = ['Random';colNames];
    
    btSt = getappdata(f,'btSt');
    btSt.colNames = colNames;
    btSt.colVals = colVals;
    setappdata(f,'btSt',btSt);
end