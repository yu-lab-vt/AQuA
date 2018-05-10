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
bEvtBtn = uix.HButtonBox('Parent',bEvt,'Spacing',10);
tb = uitable(bEvt,'Data',zeros(0,5),'Tag','evtTable');
tb.ColumnName = {'','Index','Frame','Size','Duration','df/f','Tau'};
tb.ColumnWidth = {20 40 45 45 60 45 45};
tb.ColumnEditable = [true,false,false,false,false,false];
bEvt.Heights = [15,-1];
uicontrol(bEvtBtn,'String','Select all','Callback',{@ui.evt.evtMngrSelAll,f});
uicontrol(bEvtBtn,'String','Show curve','Callback',{@ui.evt.evtMngrShowCurve,f});
uicontrol(bEvtBtn,'String','Delete','Callback',{@ui.evt.evtMngrDeleteSel,f});
bEvtBtn.ButtonSize = [100,15];
end








