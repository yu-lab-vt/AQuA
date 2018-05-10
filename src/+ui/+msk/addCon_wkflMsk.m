function addCon_wkflMsk(f, pWkfl)
    % masks ***********

    % workflow panels ----
    bWkfl = uix.VBox('Parent', pWkfl, 'Spacing', 5);
    % pDraw = uix.BoxPanel('Parent', bWkfl, 'Title', 'Manually add/remove regions/landmarks');
    pMsk = uix.BoxPanel('Parent', bWkfl, 'Title', '  Load masks');
    pSave = uix.BoxPanel('Parent', bWkfl, 'Title', '  Save regions/landmarks');
    uix.Empty('Parent', bWkfl);
    bWkfl.Heights = [390, 110, -1];
    % bWkfl.Heights = [80,330,130,-1];

    % % draw or edit regions ----
    % bDraw = uix.VBox('Parent', pDraw, 'Spacing', 3, 'Padding', 3);
    % gDraw = uix.Grid('Parent', bDraw, 'Spacing', 3, 'Padding', 3);
    % uicontrol(gDraw,'Style', 'text', 'String', 'Region', 'HorizontalAlignment', 'left');
    % uicontrol(gDraw,'Style', 'text', 'String', 'Landmark', 'HorizontalAlignment', 'left');
    % uicontrol(gDraw,'String', 'Add', 'Tag', 'AddCellMsk', 'Callback', ...
    %     {@ui.msk.drawReg,f,'add', 'cell'}, 'Interruptible', 'off', 'BusyAction', 'cancel');
    % uicontrol(gDraw,'String', 'Add', 'Tag', 'AddLmMsk', 'Callback', ...
    %     {@ui.msk.drawReg,f,'add', 'landmk'}, 'Interruptible', 'off', 'BusyAction', 'cancel');
    % uicontrol(gDraw,'String', 'Remove', 'Tag', 'RmCellMsk', 'Callback', {@ui.msk.updtCursorFun, f, 'rm', 'cell'});
    % uicontrol(gDraw,'String', 'Remove', 'Tag', 'RmLmMsk', 'Callback', {@ui.msk.updtCursorFun, f, 'rm', 'landmk'});
    % gDraw.Widths = [-1,50,50];
    % gDraw.Heights = [20,20];

    % load masks ---
    bLoad = uix.VBox('Parent', pMsk, 'Spacing', 5, 'Padding', 5);
    gLoad = uix.Grid('Parent', bLoad, 'Spacing', 5, 'Padding', 5);
    uicontrol(gLoad, 'Style', 'text', 'String', 'Region mask', 'HorizontalAlignment', 'left');
    uicontrol(gLoad, 'Style', 'text', 'String', 'Landmark mask', 'HorizontalAlignment', 'left');
    uicontrol(gLoad, 'String', 'Add folder', 'Callback', {@ui.msk.readMsk, f, 'folder', 'region'});
    uicontrol(gLoad, 'String', 'Add folder', 'Callback', {@ui.msk.readMsk, f, 'folder', 'landmark'});
    uicontrol(gLoad, 'String', 'Add file', 'Callback', {@ui.msk.readMsk, f, 'file', 'region'});
    uicontrol(gLoad, 'String', 'Add file', 'Callback', {@ui.msk.readMsk, f, 'file', 'landmark'});
    gLoad.Widths = [-1, 80, 80];
    gLoad.Heights = [20, 20];
    % uix.Empty('Parent', bLoad);

    % % use current movie
    % uicontrol(bLoad,'Style', 'text', 'String', 'Mean project current movie as', 'HorizontalAlignment', 'left');
    % bLoadCur = uix.HBox('Parent', bLoad);
    % uicontrol(bLoadCur,'Style', 'popupmenu', 'String', {'Region mask', 'landmark mask'}, 'Value', 1, 'Tag', 'curMovAsMskType');
    % uix.Empty('Parent', bLoadCur);
    % uicontrol(bLoadCur,'String', 'Add');
    % bLoadCur.Widths = [100,10,50];
    % uix.Empty('Parent', bLoad);

    % list of added masks
    t = uitable(bLoad, 'Data', zeros(0, 3), 'Tag', 'mskTable');
    t.ColumnName = {'', 'Mask name', 'Type'};
    t.ColumnEditable = [false, false, false];
    t.ColumnWidth = {15, 170, 65};
    t.CellSelectionCallback = {@ui.msk.mskLstViewer, f, 'select'};
    uix.Empty('Parent', bLoad);
    bLoadBtn = uix.HButtonBox('Parent', bLoad);
    uicontrol(bLoadBtn, 'String', 'Remove', 'Callback', {@ui.msk.mskLstViewer, f, 'remove'});
    uix.Empty('Parent', bLoad);

    bLoad.Heights = [60, -1, 3, 20, 5];
    % bLoad.Heights = [60,5,20,25,10,-1,20];

    % save masks and back to main UI ----
    bSave = uix.VBox('Parent', pSave, 'Spacing', 5, 'Padding', 5);
    gSave = uix.Grid('Parent', bSave, 'Spacing', 3, 'Padding', 3);
    uicontrol(gSave, 'Style', 'text', 'String', 'Save region using:', 'HorizontalAlignment', 'left');
    uicontrol(gSave, 'Style', 'text', 'String', 'Save landmark using:', 'HorizontalAlignment', 'left');
    uicontrol(gSave, 'Style', 'popupmenu', 'String', {'AND', 'OR'}, 'Value', 1, 'Tag', 'saveMskRegOp');
    uicontrol(gSave, 'Style', 'popupmenu', 'String', {'AND', 'OR'}, 'Value', 1, 'Tag', 'saveMskLmkOp');
    gSave.Widths = [-1, 60];
    gSave.Heights = [20, 20];
    uix.Empty('Parent', bSave);
    bSaveBtn = uix.HButtonBox('Parent', bSave, 'Spacing', 20);
    uicontrol(bSaveBtn, 'String', 'Apply & back', 'Callback', {@ui.msk.saveMsk, f, 0});
    uicontrol(bSaveBtn, 'String', 'Discard & back', 'Callback', {@ui.msk.saveMsk, f, 1});
    bSaveBtn.ButtonSize = [100, 20];
    bSave.Heights = [50, -1, 20];

end 
