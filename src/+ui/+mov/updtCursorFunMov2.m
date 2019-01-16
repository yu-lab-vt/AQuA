function updtCursorFunMov2(~,~,f,op)
    lbl = 'maskLst';
    btSt = getappdata(f,'btSt');
    % btSt.rmLbl = lbl;
    % setappdata(f,'btSt');
    
    fh = guidata(f);
    col = getappdata(f,'col');
    fh.AddBuilder.BackgroundColor = col;
    fh.RemoveBuilder.BackgroundColor = col;
    fh.AddBuilder.ForegroundColor = [0 0 0];
    fh.RemoveBuilder.ForegroundColor = [0 0 0];

    fh.imsMsk.ButtonDownFcn = [];
    
    if strcmp([op,lbl],btSt.clickSt)==1
        btSt.clickSt = [];
        setappdata(f,'btSt',btSt);
        return
    end
    
    if strcmp(op,'add')
        fh.AddBuilder.BackgroundColor = [0.3 0.3 0.7];
        fh.AddBuilder.ForegroundColor = [1 1 1];
        ui.mov.drawReg2([],[],f,op,lbl);
        fh.AddBuilder.BackgroundColor = col;
        fh.RemoveBuilder.BackgroundColor = col;
        fh.AddBuilder.ForegroundColor = [0 0 0];
        fh.RemoveBuilder.ForegroundColor = [0 0 0];
        btSt.clickSt = [];
    elseif strcmp(op,'rm')
        fh.RemoveBuilder.BackgroundColor = [0.3 0.3 0.7];
        fh.RemoveBuilder.ForegroundColor = [1 1 1];
        fh.imsMsk.ButtonDownFcn = {@ui.mov.movClick2,f,op,lbl};
        guidata(f,fh);
        btSt.clickSt = [op,lbl];
    else
        ui.mov.clearBuilderMask([],[],f,op,lbl);
    end
        
    setappdata(f,'btSt',btSt);    
end

