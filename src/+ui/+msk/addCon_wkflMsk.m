function addCon_wkflMsk(f, pWkfl)

    % workflow panels ----
    bWkfl = uix.VBox('Parent', pWkfl, 'Spacing', 5);
    % pDraw = uix.BoxPanel('Parent', bWkfl, 'Title', 'Manually add/remove regions/landmarks');
    % pFgBg = uix.BoxPanel('Parent', bWkfl, 'Title', '  Foreground and background');
    pMsk = uix.BoxPanel('Parent', bWkfl, 'Title', '  Load masks');
    pSave = uix.BoxPanel('Parent', bWkfl, 'Title', '  Save regions/landmarks');
    uix.Empty('Parent', bWkfl);
    bWkfl.Heights = [390, 150, -1];
    % bWkfl.Heights = [130, 390, 120, -1];

    % load masks ---
    bLoad = uix.VBox('Parent', pMsk, 'Spacing', 5, 'Padding', 5);
    gLoad = uix.Grid('Parent', bLoad, 'Spacing', 5, 'Padding', 5);
    uicontrol(gLoad, 'Style', 'text', 'String', 'Region', 'HorizontalAlignment', 'left');
    uicontrol(gLoad, 'Style', 'text', 'String', 'Region maker', 'HorizontalAlignment', 'left');
    uicontrol(gLoad, 'Style', 'text', 'String', 'Landmark', 'HorizontalAlignment', 'left');
    uicontrol(gLoad, 'String', 'Self', 'Callback', {@ui.msk.readMsk, f, 'self', 'region'});
    uicontrol(gLoad, 'String', 'Self', 'Callback', {@ui.msk.readMsk, f, 'self', 'regionMarker'});
    uicontrol(gLoad, 'String', 'Self', 'Callback', {@ui.msk.readMsk, f, 'self', 'landmark'});
    uicontrol(gLoad, 'String', 'Folder', 'Callback', {@ui.msk.readMsk, f, 'folder', 'region'});
    uicontrol(gLoad, 'String', 'Folder', 'Callback', {@ui.msk.readMsk, f, 'folder', 'regionMarker'});
    uicontrol(gLoad, 'String', 'Folder', 'Callback', {@ui.msk.readMsk, f, 'folder', 'landmark'});
    uicontrol(gLoad, 'String', 'File', 'Callback', {@ui.msk.readMsk, f, 'file', 'region'});
    uicontrol(gLoad, 'String', 'File', 'Callback', {@ui.msk.readMsk, f, 'file', 'regionMarker'});
    uicontrol(gLoad, 'String', 'File', 'Callback', {@ui.msk.readMsk, f, 'file', 'landmark'});
    gLoad.Widths = [-1, 60, 60, 60];
    gLoad.Heights = [20, 20, 20];
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
    
    % Manually Select
    gSelect = uix.Grid('Parent', bLoad, 'Spacing', 5, 'Padding', 5);
    uicontrol(gSelect, 'Style', 'text', 'String', 'Manually Select', 'HorizontalAlignment', 'left');
    uicontrol(gSelect, 'String', 'Clear', 'Tag','Clear', 'Callback', {@ui.mov.updtCursorFunMov2,f,'clear'});
    uicontrol(gSelect, 'String', 'Add', 'Tag','AddBuilder', 'Callback', {@ui.mov.updtCursorFunMov2,f,'add'});
    uicontrol(gSelect, 'String', 'Remove', 'Tag','RemoveBuilder', 'Callback', {@ui.mov.updtCursorFunMov2,f,'rm'});
    gSelect.Widths = [-1, 60, 60, 60];
    gSelect.Heights = [20];
    
    bLoad.Heights = [90, -1, 3, 20, 5, 25];
    
    % save masks and back to main UI ----
    bSave = uix.VBox('Parent', pSave, 'Spacing', 5, 'Padding', 5);
    gSave = uix.Grid('Parent', bSave, 'Spacing', 5, 'Padding', 3);
    uicontrol(gSave, 'Style', 'text', 'String', 'Role of region markers', 'HorizontalAlignment', 'left');
    uicontrol(gSave, 'Style', 'text', 'String', 'Combine region masks', 'HorizontalAlignment', 'left');
    uicontrol(gSave, 'Style', 'text', 'String', 'Combine landmark masks', 'HorizontalAlignment', 'left');
    uicontrol(gSave, 'Style', 'popupmenu', 'String', {'Segment region', 'Remove region'}, 'Value', 1, 'Tag', 'saveMarkerOp');
    uicontrol(gSave, 'Style', 'popupmenu', 'String', {'OR', 'AND', 'SUB'}, 'Value', 1, 'Tag', 'saveMskRegOp');
    uicontrol(gSave, 'Style', 'popupmenu', 'String', {'OR', 'AND', 'SUB'}, 'Value', 1, 'Tag', 'saveMskLmkOp');
    gSave.Widths = [-1, 120];
    gSave.Heights = [20, 20, 20];
    uix.Empty('Parent', bSave);
    bSaveBtn = uix.HButtonBox('Parent', bSave, 'Spacing', 20);
    uicontrol(bSaveBtn, 'String', 'Apply & back', 'Callback', {@ui.msk.saveMsk, f, 0});
    uicontrol(bSaveBtn, 'String', 'Discard & back', 'Callback', {@ui.msk.saveMsk, f, 1});
    bSaveBtn.ButtonSize = [100, 20];
    uix.Empty('Parent', bSave);
    bSave.Heights = [75, -1, 20, 5];

end 
