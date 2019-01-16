function movAddAll(~,~,f)
% Add All filtered events to favorite table

ov = getappdata(f,'ov');
ov0 = ov('Events');
btSt = getappdata(f,'btSt');

xSel = ones(numel(ov0.sel),1);
if ~isempty(btSt.filterMsk)
    xSel = xSel.*btSt.filterMsk;
end

% add all filtered to favortie
evtIdx = find(xSel>0);
lst = btSt.evtMngrMsk;
lst = union(lst,evtIdx);
btSt.evtMngrMsk = lst;
setappdata(f,'btSt',btSt);

% refresh event manager
ui.evt.evtMngrRefresh([],[],f);                       

% refresh movie
ui.movStep(f,[],[],1);

end


