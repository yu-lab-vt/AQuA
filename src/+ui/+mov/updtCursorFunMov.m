function updtCursorFunMov(~,~,f,op,lbl)
    btSt = getappdata(f,'btSt');
    % btSt.rmLbl = lbl;
    % setappdata(f,'btSt');
    
    fh = guidata(f);
    col = getappdata(f,'col');
    fh.AddLm.BackgroundColor = col;
    fh.AddCell.BackgroundColor = col;
    fh.AddLm.ForegroundColor = [0 0 0];
    fh.AddCell.ForegroundColor = [0 0 0];
    fh.RmLm.BackgroundColor = col;
    fh.RmCell.BackgroundColor = col;
    fh.RmLm.ForegroundColor = [0 0 0];
    fh.RmCell.ForegroundColor = [0 0 0];
    fh.viewFavClick.BackgroundColor = col;
    fh.delResClick.BackgroundColor = col;
    fh.viewFavClick.ForegroundColor = [0 0 0];
    fh.delResClick.ForegroundColor = [0 0 0];
    
    fh.ims.im1.ButtonDownFcn = [];
    fh.ims.im2a.ButtonDownFcn = [];
    fh.ims.im2b.ButtonDownFcn = [];
    
    if strcmp([op,lbl],btSt.clickSt)==1
        btSt.clickSt = [];
        setappdata(f,'btSt',btSt);
        return
    end
    
    switch lbl
        case 'cell'
            if strcmp(op,'add')
                fh.AddCell.BackgroundColor = [0.3 0.3 0.7];
                fh.AddCell.ForegroundColor = [1 1 1];
            else
                fh.RmCell.BackgroundColor = [0.3 0.3 0.7];
                fh.RmCell.ForegroundColor = [1 1 1];
            end
        case 'landmk'
            if strcmp(op,'add')
                fh.AddLm.BackgroundColor = [0.3 0.3 0.7];
                fh.AddLm.ForegroundColor = [1 1 1];
            else
                fh.RmLm.BackgroundColor = [0.3 0.3 0.7];
                fh.RmLm.ForegroundColor = [1 1 1];
            end
        case 'viewFav'
            fh.viewFavClick.BackgroundColor = [0.3 0.3 0.7];
            fh.viewFavClick.ForegroundColor = [1 1 1];
        case 'delRes'
            fh.delResClick.BackgroundColor = [0.3 0.3 0.7];
            fh.delResClick.ForegroundColor = [1 1 1];
    end
    
    if strcmp(op,'add')
        ui.mov.drawReg([],[],f,op,lbl);
        fh.AddLm.BackgroundColor = col;
        fh.AddCell.BackgroundColor = col;
        fh.AddLm.ForegroundColor = [0 0 0];
        fh.AddCell.ForegroundColor = [0 0 0];
        btSt.clickSt = [];
    elseif strcmp(op,'addrm')&&strcmp(lbl,'addAll')
        ui.mov.movAddAll([],[],f);
        btSt = getappdata(f,'btSt');
    else
        fh.ims.im1.ButtonDownFcn = {@ui.mov.movClick,f,op,lbl};
        fh.ims.im2a.ButtonDownFcn = {@ui.mov.movClick,f,op,lbl};
        fh.ims.im2b.ButtonDownFcn = {@ui.mov.movClick,f,op,lbl};
        guidata(f,fh);
        btSt.clickSt = [op,lbl];
    end
        
    setappdata(f,'btSt',btSt);    
end

