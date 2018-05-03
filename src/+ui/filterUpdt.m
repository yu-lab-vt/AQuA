function filterUpdt(~,~,f)
% filterInit initialize filtering table

fh = guidata(f);
fts = getappdata(f,'fts');
tb = fh.filterTable;

btSt = getappdata(f,'btSt');
fCmd = btSt.ftsCmd;

nEvt = numel(fts.basic.area);
xSel = ones(nEvt,1);

for ii=1:numel(fCmd)
    s0 = tb.Data{ii,1};
    if s0==0
        continue
    end
    xmin = tb.Data{ii,3};
    xmax = tb.Data{ii,4};
    if ~isnumeric(xmin)
        try
            xmin = str2double(xmin);
            xmax = str2double(xmax);
        catch
            return
        end
    end
    cmd0 = ['f0=',fCmd{ii},';'];
    eval(cmd0);
    xSel(isnan(f0)) = 0;
    xSel(f0<xmin | f0>xmax) = 0;
end

btSt.filterMsk = xSel;
setappdata(f,'btSt',btSt);

ui.updtEvtOvShowLst([],[],f);


end