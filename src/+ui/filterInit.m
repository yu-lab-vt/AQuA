function filterInit(~,~,f)
% filterInit initialize filtering table

fh = guidata(f);
fts = getappdata(f,'fts');
tb = fh.filterTable;

fName = {'Area (um^2)','dF/F', 'Duration (s)'};
fVar = {'area','dffMax','width55'};  % old feature name
fCmd = {'fts.basic.area',...  % new feature name
    'fts.curve.dffMax',...
    'fts.curve.width55'};
T = cell(numel(fCmd),4);
for ii=1:numel(fVar)
    T{ii,1} = false;
    T{ii,2} = fName{ii};
    f00 = fVar{ii};
    if isfield(fts,f00)
        x = fts.(f00);
    else
        cmd0 = ['x=',fCmd{ii},';'];
        eval(cmd0);
    end
    T{ii,3} = nanmin(x);
    T{ii,4} = nanmax(x);
end

tb.Data = T;
tb.ColumnName = {'','Feature','Min','Max'};
tb.ColumnWidth = {20 'auto' 60 60};
tb.ColumnEditable = [true,false,true,true];

btSt = getappdata(f,'btSt');
btSt.ftsFilter = fVar;
btSt.ftsCmd = fCmd;
setappdata(f,'btSt',btSt);

end