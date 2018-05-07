function addCon_wkfl(f,pWkfl)

% workflow panels ----
bWkfl = uix.VBox('Parent',pWkfl,'Tag','bWkfl','Spacing',10);
pDraw = uix.BoxPanel('Parent',bWkfl,'Title','Direction, regions, landmarks','Tag','pDraw');
pDeOut = uix.BoxPanel('Parent',bWkfl,'Title','Detection pipeline','Tag','pDeOut');
pFilter = uix.BoxPanel('Parent',bWkfl,'Title','Filtering','Tag','pFilter');
pExport = uix.BoxPanel('Parent',bWkfl,'Title','Export','Tag','pExport');
% pSys = uix.BoxPanel('Parent',bWkfl,'Title','Others','Tag','pSys');
uix.Empty('Parent',bWkfl);
bWkfl.Heights = [130,390,140,80,-1];
% bWkfl.Heights = [130,390,140,80,60,-1];

% draw regions ----
bDraw = uix.VBox('Parent',pDraw,'Spacing',3,'Padding',3);
gDraw = uix.Grid('Parent',bDraw,'Spacing',3,'Padding',3);
uicontrol(gDraw,'Style','text','String','Cell boundary','HorizontalAlignment','left');
uicontrol(gDraw,'Style','text','String','Landmark (like soma)','HorizontalAlignment','left');
uicontrol(gDraw,'Style','text','String','Anterior direction','HorizontalAlignment','left');
uicontrol(gDraw,'String','Add','Tag','AddCell','Callback',...
    {@ui.mov.drawReg,f,'add','cell'},'Interruptible','off','BusyAction','cancel');
uicontrol(gDraw,'String','Add','Tag','AddLm','Callback',...
    {@ui.mov.drawReg,f,'add','landmk'},'Interruptible','off','BusyAction','cancel');
uicontrol(gDraw,'String','Draw','Tag','drawNorth','Callback',...
    {@ui.mov.drawReg,f,'arrow','diNorth'},'Interruptible','off','BusyAction','cancel');
uicontrol(gDraw,'String','Remove','Tag','RmCell','Callback',{@ui.mov.updtCursorFunMov,f,'rm','cell'});
uicontrol(gDraw,'String','Remove','Tag','RmLm','Callback',{@ui.mov.updtCursorFunMov,f,'rm','landmk'});
uix.Empty('Parent',gDraw);
gDraw.Widths = [-1,50,50];
gDraw.Heights = [20,20,20];
bDrawBt = uix.HButtonBox('Parent',bDraw,'Spacing',10,'ButtonSize',[120,20]);
uicontrol(bDrawBt,'String','Update features','Tag','updtFeature1',...
    'Callback',{@ui.detect.updtFeature,f,1},'Enable','off');
bDraw.Heights = [-1,25];

% event detection top ----
ui.com.addDetect(f,pDeOut);

% filtering ----
bFilter = uix.VBox('Parent',pFilter,'Spacing',3,'Padding',3);
uitable(bFilter,'Data',zeros(5,4),'Tag','filterTable','CellEditCallback',{@ui.detect.filterUpdt,f});
% bFilter.Heights = 50;

% exporting ----
bExp = uix.VBox('Parent',pExport,'Spacing',5,'Padding',5);
% uicontrol(bExp,'Style','checkbox','String','Filtered events','Value',1,'Tag','expEvtFlt');
% uicontrol(bExp,'Style','checkbox','String','Selected events','Value',1,'Tag','expEvtMngr');
uicontrol(bExp,'Style','checkbox','String','Movie with overlay','Value',1,'Tag','expMov');
% uicontrol(bExp,'Style','checkbox','String','Features','Tag','expFea');
% uicontrol(bExp,'Style','checkbox','String','Curves','Tag','expCur');
bExpBtn = uix.HButtonBox('Parent',bExp);
uicontrol(bExpBtn,'String','Export & Save','Callback',{@ui.proj.getOutputFolder,f});
bExpBtn.ButtonSize = [120,20];

% % misc. tools ----
% bSys = uix.HButtonBox('Parent',pSys,'Spacing',15);
% uicontrol(bSys,'String','Restart','Callback',{@ui.proj.back2welcome,f});
% uicontrol(bSys,'String','Send to workspace','Callback',{@ui.proj.exportVar2Base,f});
% bSys.ButtonSize = [140,20];
end


