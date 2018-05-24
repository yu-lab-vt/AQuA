function postRun(~,~,f,evtLst,datR,ovName)
    
    opts = getappdata(f,'opts');
    
    % overlays object
    ov = getappdata(f,'ov');
    ov0 = ui.over.getOv(f,evtLst,opts.sz,datR);
    ov0.name = ovName;
    ov0.colorCodeType = {'Random'};
    ov(ov0.name) = ov0;
    setappdata(f,'ov',ov);
    
    % update UI
    btSt = getappdata(f,'btSt');
    btSt.overlayDatSel = ov0.name;
    btSt.overlayColorSel = 'Random';
    setappdata(f,'btSt',btSt);
    ui.over.updateOvFtMenu([],[],f);
    
    % show movie with overlay
    ui.movStep(f);
    
end