function addDetect(f,pDeOut)
% event detection top
bDeOut = uix.VBox('Parent',pDeOut,'Padding',3,'Spacing',3);
pDeAct = uix.Panel('Parent',bDeOut,'Title','Step 1: active voxels');
pDePhase = uix.Panel('Parent',bDeOut,'Title','Step 2: super voxels and phases','Tag','pPhase');
pDeEvent = uix.Panel('Parent',bDeOut,'Title','Step 3: events','Tag','pEvt');
bDeOut.Heights = [120,100,-1];
% bDeOut.Heights = [120,100,140];

% event detection: active voxels
bAct = uix.VBox('Parent',pDeAct);
gAct = uix.Grid('Parent',bAct);
uicontrol(gAct,'Style','edit','String','2','Tag','thrArScl');
uicontrol(gAct,'Style','edit','String','0.5','Tag','smoXY');
uicontrol(gAct,'Style','edit','String','8','Tag','minSize');
uicontrol(gAct,'Style','text','String','Intensity threshold scaling factor','HorizontalAlignment','left');
uicontrol(gAct,'Style','text','String','Smoothing (sigma)','HorizontalAlignment','left');
uicontrol(gAct,'Style','text','String','Minimum size (pixels)','HorizontalAlignment','left');
gAct.Widths = [50,-1];
gAct.Heights = [15,15,15];
gAct.Padding = 10;
gAct.Spacing = 8;
bActBt = uix.HButtonBox('Parent',bAct,'Spacing',10,'ButtonSize',[80,15]);
uicontrol(bActBt,'String','Run','Tag','wkflActRun','Callback',{@ui.actRun,f});
bAct.Heights = [80,20];

% event detection: superpixels and rising time
bPhase = uix.VBox('Parent',pDePhase);
gPhase = uix.Grid('Parent',bPhase);
uicontrol(gPhase,'Style','edit','String','2','Tag','thrTWScl');
uicontrol(gPhase,'Style','edit','String','1','Tag','thrExtZ');
uicontrol(gPhase,'Style','text','String','Temporal cut threshold','HorizontalAlignment','left');
uicontrol(gPhase,'Style','text','String','Growing z threshold','HorizontalAlignment','left');
gPhase.Widths = [50,-1];
gPhase.Heights = [15,15];
gPhase.Padding = 10;
gPhase.Spacing = 8;
bPhaseBt = uix.HButtonBox('Parent',bPhase,'Spacing',10,'ButtonSize',[80,15]);
uicontrol(bPhaseBt,'String','Run','Tag','wkflPhaseRun','Callback',{@ui.phaseRun,f});
bPhase.Heights = [60,20];

% event detection: events
bEvt = uix.VBox('Parent',pDeEvent);
gEvt = uix.Grid('Parent',bEvt);
uicontrol(gEvt,'Style','edit','String','2','Tag','cRise');
uicontrol(gEvt,'Style','edit','String','0.5','Tag','cDelay');
% uicontrol(gEvt,'Style','edit','String','0.5','Tag','cOver');
uicontrol(gEvt,'Style','edit','String','0.1','Tag','evtGtwSmo');
uicontrol(gEvt,'Style','edit','String','0.1','Tag','mergeEventDiscon');
uicontrol(gEvt,'Style','text','String','Rising time uncertainty (frames)','HorizontalAlignment','left');
uicontrol(gEvt,'Style','text','String','Slowest delay in propagation (frames)','HorizontalAlignment','left');
% uicontrol(gEvt,'Style','text','String','Minimum overlapping (ratio)','HorizontalAlignment','left');
uicontrol(gEvt,'Style','text','String','Smoothness for propagation estimation','HorizontalAlignment','left');
uicontrol(gEvt,'Style','text','String','Connect nearby events (pixels)','HorizontalAlignment','left');
gEvt.Widths = [50,-1];
gEvt.Heights = [15,15,15,15];
gEvt.Padding = 10;
gEvt.Spacing = 8;
bEvtBt = uix.HButtonBox('Parent',bEvt,'Spacing',10,'ButtonSize',[80,15]);
uicontrol(bEvtBt,'String','Run','Tag','wkflEvtRun','Callback',{@ui.evtRun,f});
bEvt.Heights = [120,20];

end

