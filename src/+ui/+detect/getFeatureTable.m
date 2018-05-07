function getFeatureTable(f)

bd = getappdata(f,'bd');
if bd.isKey('landmk')
    bd1 = bd('landmk');
    lmkLst = cell(numel(bd1),1);
    for ii=1:numel(bd1)
        lmkLst{ii} = bd1{ii}{1};
    end
else
    lmkLst = [];
end

% show in event manager and for exporting
fts = getappdata(f,'fts');
tb = getappdata(f,'userFeatures');
nEvt = numel(fts.basic.area);
nFt = numel(tb.Name);
ftsTb = nan(nFt,nEvt);
ftsName = cell(nFt,1);
ftsCnt = 1;
dixx = fts.notes.propDirectionOrder;
for ii=1:nFt
    cmdSel0 = tb.Script{ii};
    ftsName0 = tb.Name{ii};
    % if find landmark or direction
    if ~isempty(strfind(cmdSel0,'xxLmk')) %#ok<STREMP>
        for xxLmk=1:numel(lmkLst)
            try
                eval([cmdSel0,';']);
            catch
                fprintf('Feature "%s" not used\n',ftsName0)
                x = nan(nEvt,1);
            end
            ftsTb(ftsCnt,:) = reshape(x,1,[]);
            ftsName1 = [ftsName0,' - landmark ',num2str(xxLmk)];
            ftsName{ftsCnt} = ftsName1;
            ftsCnt = ftsCnt + 1;
        end
    elseif ~isempty(strfind(cmdSel0,'xxDi')) %#ok<STREMP>
        for xxDi=1:4
            try
                eval([cmdSel0,';']);
            catch
                fprintf('Feature "%s" not used\n',ftsName0)
                x = nan(nEvt,1);
            end
            ftsTb(ftsCnt,:) = reshape(x,1,[]);
            ftsName1 = [ftsName0,' - ',dixx{xxDi}];
            ftsName{ftsCnt} = ftsName1;
            ftsCnt = ftsCnt + 1;
        end
    else
        try
            eval([cmdSel0,';']);
        catch
            fprintf('Feature "%s" not used\n',ftsName0)
            x = nan(nEvt,1);
        end
        ftsTb(ftsCnt,:) = reshape(x,1,[]);
        ftsName{ftsCnt} = ftsName0;
        ftsCnt = ftsCnt + 1;
    end
end
featureTable = table(ftsTb,'RowNames',ftsName);
setappdata(f,'featureTable',featureTable);

end


