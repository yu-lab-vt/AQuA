function feaRun(~,~,f)
    
    fh = guidata(f);
    opts = getappdata(f,'opts');
    opts.ignoreTau = fh.ignoreTau.Value==1;
    setappdata(f,'opts',opts);
    
    % features
    ui.detect.updtFeature([],[],f,0);
    
    % enable feature overlay
    ui.over.chgOv([],[],f,1)
    
    
    
    fh.updtFeature1.Enable = 'on';
    fh.pFilter.Visible = 'on';
    fh.pEvtMngr.Visible = 'on';
    fh.pExport.Visible = 'on';
    fh.pSys.Visible = 'on';
    
end