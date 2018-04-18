function updtEvtOvShowLst(~,~,f)
% updtEvtOvShowLst update the list of events whose overlay should be shown

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

% if fh.showFilterOut.Value==0
%     xSel = xSel.*btSt.filterMsk;
% end
% if fh.showOutsideCell.Value==0
%  
% end
% if fh.hideNotInEvtMngr.Value==1
%     try
%         xSel = xSel.*btSt.evtMngrMsk;
%     catch
%     end
% end
% if fh.hideInEvtMngr.Value==1
%     try
%         xSel = xSel.*(1-btSt.evtMngrMsk);
%     catch
%     end
% end

ov0.sel = xSel>0;
ov('Events') = ov0;
setappdata(f,'ov',ov);

ui.movStep(f);

end


