function updtEvtOvShowLst(~,~,f)
% updtEvtOvShowLst update the list of events whose overlay should be shown
% determined by filter and drawn regions

% fh = guidata(f);
btSt = getappdata(f,'btSt');
ov = getappdata(f,'ov');
ov0 = ov('Events');

xSel = ones(numel(ov0.sel),1);
if ~isempty(btSt.filterMsk)
    xSel = xSel.*btSt.filterMsk;
end
if ~isempty(btSt.regMask)
    xSel = xSel.*btSt.regMask;
end

ov0.sel = xSel>0;
ov('Events') = ov0;
setappdata(f,'ov',ov);

ui.movStep(f);

end


