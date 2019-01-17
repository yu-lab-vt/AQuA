function addCon_wkfl(f,pWkfl)
    
    % workflow panels ----
    bWkfl = uix.VBox('Parent',pWkfl,'Tag','bWkfl','Spacing',10);
    pDraw = uix.BoxPanel('Parent',bWkfl,'Title','Direction, regions, landmarks','Tag','pDraw');
    pDeOut = uix.BoxPanel('Parent',bWkfl,'Title','Detection pipeline','Tag','pDeOut');
    pFilter = uix.BoxPanel('Parent',bWkfl,'Title','Proof reading','Tag','pFilter');
    pExport = uix.BoxPanel('Parent',bWkfl,'Title','Export','Tag','pExport');
    pSys = uix.BoxPanel('Parent',bWkfl,'Title','Others','Tag','pSys');
    uix.Empty('Parent',bWkfl);
    bWkfl.Heights = [110,240,190,100,60,-1];
    
    % draw regions ----
    bDraw = uix.VBox('Parent',pDraw,'Spacing',3,'Padding',3);
    gDraw = uix.Grid('Parent',bDraw,'Spacing',3,'Padding',3);
    uicontrol(gDraw,'Style','text','String','Cell boundary','HorizontalAlignment','left');
    uicontrol(gDraw,'Style','text','String','Landmark (like soma)','HorizontalAlignment','left');
    uicontrol(gDraw,'String','Add','Tag','AddCell','Callback',...
        {@ui.mov.updtCursorFunMov,f,'add','cell'},'Interruptible','off','BusyAction','cancel');
    uicontrol(gDraw,'String','Add','Tag','AddLm','Callback',...
        {@ui.mov.updtCursorFunMov,f,'add','landmk'},'Interruptible','off','BusyAction','cancel');
    uicontrol(gDraw,'String','Remove','Tag','RmCell',...
    'Callback',{@ui.mov.updtCursorFunMov,f,'rm','cell'});
    uicontrol(gDraw,'String','Remove','Tag','RmLm',...
    'Callback',{@ui.mov.updtCursorFunMov,f,'rm','landmk'});
    gDraw.Widths = [-1,50,50];
    gDraw.Heights = [20,20];
    bDrawBt = uix.HButtonBox('Parent',bDraw,'Spacing',10,'ButtonSize',[120,20]);
    uicontrol(bDrawBt,'String','Draw anterior','Tag','drawNorth','Callback',...
        {@ui.mov.drawReg,f,'arrow','diNorth'},'Interruptible','off','BusyAction','cancel');
    uicontrol(bDrawBt,'String','Mask builder',...
        'Callback',{@ui.msk.mskBuilderOpen,f},'Enable','on');
    uicontrol(bDrawBt,'String','Update features','Tag','updtFeature1',...
        'Callback',{@ui.detect.updtFeature,f,1},'Enable','off');
    uix.Empty('Parent',bDraw);
    bDraw.Heights = [-1,20,5];
    
    % event detection top ----
    ui.com.addDetectTab(f,pDeOut);
    
    % filtering ----
    bFilter = uix.VBox('Parent',pFilter,'Spacing',3,'Padding',3);
    fcon = uix.HBox('Parent',bFilter,'Spacing',5);
    uicontrol(fcon,'String','view/favourite','Tag','viewFavClick',...
        'Callback',{@ui.mov.updtCursorFunMov,f,'addrm','viewFav'});
    uicontrol(fcon,'String','delete/restore','Tag','delResClick',...
        'Callback',{@ui.mov.updtCursorFunMov,f,'addrm','delRes'});
    uitable(bFilter,'Data',zeros(5,4),'Tag','filterTable',...
        'CellEditCallback',{@ui.detect.filterUpdt,f});
    fcon2 = uix.HBox('Parent',bFilter,'Spacing',5);
    uicontrol(fcon2,'String','addAllFiltered','Tag','addAllFiltered',...
        'Callback',{@ui.mov.updtCursorFunMov,f,'addrm','addAll'});
    uicontrol(fcon2,'String','FeaturesPlot','Tag','featuresPlot',...
        'Callback',{@ui.mov.featurePlot,f});
    bFilter.Heights = [20,-1,20];
    
    % exporting ----
    bExp = uix.VBox('Parent',pExport,'Spacing',5,'Padding',5);
    % uicontrol(bExp,'Style','checkbox','String','Filtered events','Value',1,'Tag','expEvtFlt');
    % uicontrol(bExp,'Style','checkbox','String','Selected events','Value',1,'Tag','expEvtMngr');
    uicontrol(bExp,'Style','checkbox','String','Events and features','Value',1,'Tag','expEvt');
    % uicontrol(bExp,'Style','checkbox','String','Tables and maps','Value',1,'Tag','expTab');
    uicontrol(bExp,'Style','checkbox','String','Movie with overlay','Value',1,'Tag','expMov');
    % uicontrol(bExp,'Style','checkbox','String','Features','Tag','expFea');
    % uicontrol(bExp,'Style','checkbox','String','Curves','Tag','expCur');
    bExpBtn = uix.HButtonBox('Parent',bExp,'Spacing',20);
    uicontrol(bExpBtn,'String','Export / Save','Callback',{@ui.proj.getOutputFolder,f});
    bExpBtn.ButtonSize = [120,20];
    
    % misc. tools ----
    bSys = uix.HButtonBox('Parent',pSys,'Spacing',15,'Padding',5);
    uicontrol(bSys,'String','Restart','Callback',{@ui.proj.back2welcome,f});
    uicontrol(bSys,'String','Send to workspace','Callback',{@ui.proj.exportVar2Base,f});
    bSys.ButtonSize = [140,20];
end



