function getColMap(~,~,f)
   
    tb = readtable('userColors.csv','Delimiter',',','ReadVariableNames',0,'ReadRowNames',1);         
    colNames = tb.Properties.RowNames;
    tbc = table2cell(tb);
    
    % colorbrew
    nCol = numel(colNames);
    colVals = cell(nCol,1);
    for ii=1:nCol
        v0 = tbc(ii,1:end);
        %v0 = tb{ii,1:end};
        idxGood = ~cellfun(@isempty,v0);
        nGood = sum(idxGood);
        if nGood>1
            val0 = nan(1,3);
            nxx = 1;
            for jj=1:numel(v0)
                if isempty(v0{jj})
                    break
                end
                try
                    tmp = eval(['[',v0{jj},']']);
                    if numel(tmp)==3
                        val0(nxx,:) = tmp;
                        nxx = nxx + 1;
                    end
                catch
                    fprintf('Error in reading userColors.csv: %d\n',ii)
                end
            end
            colVals{ii} = val0;
        else % search in colorbrew
            c0 = colNames{ii};
            try
                colVals{ii} = brewermap(50,c0);
            catch
                fprintf('Error in reading userColors.csv (brewer): %d\n',ii)
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