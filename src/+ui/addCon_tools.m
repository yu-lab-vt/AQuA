function addCon_tools(f,pTool)
% tools panels
bTool = uix.VBox('Parent',pTool,'Spacing',10);
pLayer = uix.BoxPanel('Parent',bTool,'Title','Layers');
pEvtMngr = uix.BoxPanel('Parent',bTool,'Title','Event manager','Tag','pEvtMngr');
bTool.Heights = [580,-1];

% layer manager
bLayer = uix.VBox('Parent',pLayer,'Padding',3);
ui.addConLayer(f,bLayer);

% event manager
bEvt = uix.VBox('Parent',pEvtMngr,'Spacing',3,'Padding',3);
bEvtBtn = uix.HButtonBox('Parent',bEvt,'Spacing',10);
tb = uitable(bEvt,'Data',zeros(0,5),'Tag','evtTable');
tb.ColumnName = {'','Index','Frame','Size','Duration','df/f','Tau'};
tb.ColumnWidth = {20 40 45 45 60 45 45};
tb.ColumnEditable = [true,false,false,false,false,false];
bEvt.Heights = [15,-1];
uicontrol(bEvtBtn,'String','Select all','Callback',{@evtMngrSelAll,f});
uicontrol(bEvtBtn,'String','Show curve','Callback',{@evtMngrShowCurve,f});
uicontrol(bEvtBtn,'String','Delete','Callback',{@evtMngrDeleteSel,f});
bEvtBtn.ButtonSize = [100,15];

end


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




