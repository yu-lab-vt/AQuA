function addCon_tools(f,pTool)
% tools panels
bTool = uix.VBox('Parent',pTool,'Spacing',10);
pLayer = uix.BoxPanel('Parent',bTool,'Title','Layers');
pEvtMngr = uix.BoxPanel('Parent',bTool,'Title','Favourite','Tag','pEvtMngr');
bTool.Heights = [580,-1];

% layer manager
bLayer = uix.VBox('Parent',pLayer,'Padding',3);
ui.com.addConLayer(f,bLayer);

% event manager
bEvt = uix.VBox('Parent',pEvtMngr,'Spacing',3,'Padding',3);
bEvtBtn = uix.HButtonBox('Parent',bEvt,'Spacing',5);
tb = uitable(bEvt,'Data',zeros(0,5),'Tag','evtTable');
tb.ColumnName = {'','Index','Frame','Size','Duration','df/f','Tau'};
tb.ColumnWidth = {20 40 40 40 40 40 35};
tb.ColumnEditable = [true,false,false,false,false,false];
tb.CellSelectionCallback = {@ui.evt.evtMngrSelectOne,f};

uicontrol(bEvtBtn,'String','Select all','Callback',{@ui.evt.evtMngrSelAll,f});
uicontrol(bEvtBtn,'String','Show curve','Callback',{@ui.evt.evtMngrShowCurve,f});
uicontrol(bEvtBtn,'String','Delete','Callback',{@ui.evt.evtMngrDeleteSel,f});
uicontrol(bEvtBtn,'String','Details','Callback',{@ui.evt.showDetails,f});
bEvtBtn.ButtonSize = [100,15];

bEvtAdd = uix.HBox('Parent',bEvt,'Spacing',10);
uicontrol(bEvtAdd,'Style','text','String','Event ID','HorizontalAlignment','left');
uicontrol(bEvtAdd,'Style','edit','Tag','toolsAddEvt');
uicontrol(bEvtAdd,'String','Add to favorite','Callback',{@ui.evt.addOne,f});
uix.Empty('Parent',bEvtAdd);
bEvtAdd.Widths = [50,60,100,-1];

bEvt.Heights = [15,-1,15];

end








