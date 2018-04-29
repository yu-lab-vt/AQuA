function addCon_tools(f,pTool)
% tools panels
bTool = uix.VBox('Parent',pTool,'Spacing',10);
pLayer = uix.BoxPanel('Parent',bTool,'Title','Layers');
pEvtMngr = uix.BoxPanel('Parent',bTool,'Title','Event manager','Tag','pEvtMngr');
bTool.Heights = [450,-1];

% layer manager
bLayer = uix.VBox('Parent',pLayer,'Padding',3);
addConLayer(f,bLayer);

% event manager
bEvt = uix.VBox('Parent',pEvtMngr,'Spacing',3,'Padding',3);
bEvtBtn = uix.HButtonBox('Parent',bEvt,'Spacing',10);
tb = uitable(bEvt,'Data',zeros(0,5),'Tag','evtTable');
tb.ColumnName = {'','Index','Frame','Size','Duration','df/f'};
tb.ColumnWidth = {20 40 40 50 60 50};
tb.ColumnEditable = [true,false,false,false,false,false];

bEvt.Heights = [15,-1];

uicontrol(bEvtBtn,'String','Select all','Callback',{@evtMngrSelAll,f});
uicontrol(bEvtBtn,'String','Show curve','Callback',{@evtMngrShowCurve,f});
uicontrol(bEvtBtn,'String','Delete','Callback',{@evtMngrDeleteSel,f});
bEvtBtn.ButtonSize = [100,15];
end


% ------------------------------------------------------- %
function addConLayer(f,bLayer)
% movie
bL1 = uix.VBox('Parent',bLayer,'Spacing',1,'Padding',3);
uicontrol(bL1,'Style','text','String','--- Movie brightness/contrast ---');
uix.Empty('Parent',bL1);
uicontrol(bL1,'Style','text','String','Min','HorizontalAlignment','left');
uicontrol(bL1,'Style','slider','Tag','sldMin','Callback',{@adjMov,f});
uix.Empty('Parent',bL1);
uicontrol(bL1,'Style','text','String','Max','HorizontalAlignment','left');
uicontrol(bL1,'Style','slider','Tag','sldMax','Callback',{@adjMov,f});
uix.Empty('Parent',bL1);
uicontrol(bL1,'Style','text','String','Brightness','HorizontalAlignment','left');
uicontrol(bL1,'Style','slider','Tag','sldBri','Callback',{@adjMov,f});
bL1.Heights = [18,3,15,15,3,15,15,3,15,15];

uix.Empty('Parent',bLayer);

% overlays
bL2 = uix.VBox('Parent',bLayer,'Spacing',1,'Padding',3);
uicontrol(bL2,'Style','text','String','--- Feature overlay ---');
uix.Empty('Parent',bL2);
uicontrol(bL2,'Style','text','String','Type','HorizontalAlignment','left');
uicontrol(bL2,'Style','popupmenu','Tag','overlayDat','String',{'None'},'Callback',{@ui.chgOv,f,1});
uix.Empty('Parent',bL2);
x0 = [18,3,15,20,3];

uicontrol(bL2,'Style','text','String','Feature','HorizontalAlignment','left');
uicontrol(bL2,'Style','popupmenu','Tag','overlayFeature','String',{'Index'},'Enable','off');
uicontrol(bL2,'Style','text','String','Color','HorizontalAlignment','left');
uicontrol(bL2,'Style','popupmenu','Tag','overlayColor','String',{'Random','GreenRed'},'Enable','off');
uix.Empty('Parent',bL2);
x1 = [15,20,15,20,3];

bDrawBt = uix.HButtonBox('Parent',bL2,'Spacing',10,'ButtonSize',[120,20]);
uicontrol(bDrawBt,'String','Update overlay','Tag','updtFeature','Callback',{@ui.chgOv,f,2});
uicontrol(bDrawBt,'String','Read user feature','Tag','addUserFeature','Callback',{@ui.chgOv,f,0});
uix.Empty('Parent',bL2);
x2 = [20,3];

uicontrol(bL2,'Style','text','String','Min','HorizontalAlignment','left');
uicontrol(bL2,'Style','slider','Tag','sldMinOv','Callback',{@adjMov,f},'Enable','off');
uicontrol(bL2,'Style','text','String','Max','HorizontalAlignment','left');
uicontrol(bL2,'Style','slider','Tag','sldMaxOv','Callback',{@adjMov,f},'Enable','off');
uicontrol(bL2,'Style','text','String','Brightness','HorizontalAlignment','left');
uicontrol(bL2,'Style','slider','Tag','sldBriOv','Callback',{@adjMov,f});
x3 = [15,15,15,15,15,15];

bL2.Heights = [x0,x1,x2,x3];
bLayer.Heights = [130,-1,280];
end

% ------------------------------------------------------- %
function evtMngrSelAll(~,~,f)
fh = guidata(f);
tb = fh.evtTable;
dat = tb.Data;
for ii=1:size(dat,1)
    dat{ii,1} = true;
end
tb.Data = dat;
end

function evtMngrShowCurve(~,~,f)
fh = guidata(f);
tb = fh.evtTable;
dat = tb.Data;
idxGood = [];
for ii=1:size(dat,1)
    if dat{ii,1}==1
        idxGood = union(dat{ii,2},idxGood);
    end
end
if ~isempty(idxGood)
    ui.curveRefresh([],[],f,idxGood);
end
end

function evtMngrDeleteSel(~,~,f)
fh = guidata(f);
btSt = getappdata(f,'btSt');
tb = fh.evtTable;
dat = tb.Data;
idxGood = [];
for ii=1:size(dat,1)
    if dat{ii,1}==0
        idxGood = union(dat{ii,2},idxGood);
    end
end
btSt.evtMngrMsk = idxGood;
setappdata(f,'btSt',btSt);
ui.evtMngrRefresh([],[],f);
ui.movStep(f);
end

% ------------------------------------------------------- %
function adjMov(~,~,f)
fh = guidata(f);
scl = getappdata(f,'scl');
scl.min = fh.sldMin.Value;
scl.max = fh.sldMax.Value;
scl.bri = fh.sldBri.Value;
scl.minOv = fh.sldMinOv.Value;
scl.maxOv = fh.sldMaxOv.Value;
scl.briOv = fh.sldBriOv.Value;
setappdata(f,'scl',scl);
ui.movStep(f);
end





