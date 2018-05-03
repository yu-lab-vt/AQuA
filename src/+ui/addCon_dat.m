function im = addCon_dat(f,pDat)

% data panels
bDat = uix.VBox('Parent',pDat);
pImgTool = uix.HBox('Parent',bDat);  % zoom in/out, pan, jump, frame number ...
uix.Empty('Parent',bDat);

pMov = axes('Parent',bDat,'ActivePositionProperty','Position','Tag','mov');
pMov.XTick = [];
pMov.YTick = [];
d0 = zeros(100,100);
pMov.XLim = [1 100];
pMov.YLim = [1 100];
im = image('CData',flipud(d0));
im.CDataMapping = 'scaled';
im.ButtonDownFcn = {@ui.movClick,f,'sel','evt'};  % show clicked event
pMov.DataAspectRatio = [1 1 1];

uix.Empty('Parent',bDat);
pImgCon = uix.HBox('Parent',bDat);  % play, scroll bar ...
uix.Empty('Parent',bDat);
% pCurveTool = uix.HBox('Parent',bDat);  % select curve, zoom curve ...

pCurve = axes('Parent',bDat,'ActivePositionProperty','Position','Tag','curve');
pCurve.XTick = [];
pCurve.YTick = [];
pCurve.YLim = [-0.1,0.1];
% xx = 1:1000; yy = sin(xx*0.1); line(xx,yy);
bDat.Heights = [15,5,-1,5,20,15,200];

% image tools
uix.Empty('Parent',pImgTool);
uicontrol(pImgTool,'String','Pan','Tag','pan','Callback',{@movPan,f});
% uicontrol(pImgTool,'String','Zoom in');
uicontrol(pImgTool,'String','Zoom','Tag','zoom','Callback',{@movZoom,f});
uicontrol(pImgTool,'Style','text','String','Jump to');
uicontrol(pImgTool,'Style','edit','String','1','Callback',{@jumpTo,f},'Tag','jumpTo');
uicontrol(pImgTool,'Style','text','String','Playback frame rate');
uicontrol(pImgTool,'Style','edit','String','5','Tag','playbackRate');
uix.Empty('Parent',pImgTool);
uicontrol(pImgTool,'Style','text','String','1/1','HorizontalAlignment','right','Tag','curTime');
uix.Empty('Parent',pImgTool);
pImgTool.Spacing = 10;
pImgTool.Widths = [10,60,60,40,50,120,50,-1,200,10];

% image play
uix.Empty('Parent',pImgCon);
uicontrol(pImgCon,'String','Play','Callback',{@playMov,f},'Tag','play');
uicontrol(pImgCon,'String','Pause','Callback',{@pauseMov,f});
h00 = uicomponent(pImgCon,'style','javax.swing.JScrollBar','Tag','sldMov','Orientation',0);  % Java
h00.AdjustmentValueChangedCallback = {@stepOne,f};
% uicontrol(pImgCon,'Style','slider','Min',0,'Max',100,'Value',1,'SliderStep',[0.01 0.1],...
%     'Tag','sldMov','Callback',{@stepOne,f});
uix.Empty('Parent',pImgCon);
pImgCon.Widths = [15,50,50,-1,15];

% curve tool
% uicontrol(pCurveTool,'String','Select');
% uicontrol(pCurveTool,'String','Inspect value');
% uix.Empty('Parent',pCurveTool);
% pCurveTool.Widths = [50,100,-1];
% pCurveTool.Spacing = 10;
end

% -------------------------------------------------------------------- %
% movie navigation
function stepOne(~,~,f)
fh = guidata(f);
n = round(fh.sldMov.Value);
ui.movStep(f,n);
end

function jumpTo(~,~,f)
fh = guidata(f);
try
    n = str2double(fh.jumpTo.String);
catch
    msgbox('Invalid number');
end
fh.sldMov.Value = n;
ui.movStep(f,n);
end

function playMov(~,~,f)
fh = guidata(f);
fh.play.Enable = 'off';
try 
    pauseTime = 1/str2double(fh.playbackRate.String);
catch
    pauseTime = 0.2;
end
btSt = getappdata(f,'btSt');
btSt.play = 1;
setappdata(f,'btSt',btSt);
n0 = round(fh.sldMov.Value);
scl = getappdata(f,'scl');
for nn=n0:scl.T
    btSt = getappdata(f,'btSt');
    playx = btSt.play;
    if playx==0  % interrupted by pauseMov
        break
    end
    ui.movStep(f,nn);
    fh.sldMov.Value = nn;
    pause(pauseTime);  % !! add frame rate control
end
fh.play.Enable = 'on';
end

function pauseMov(~,~,f)
btSt = getappdata(f,'btSt');
btSt.play = 0;
setappdata(f,'btSt',btSt);
end

% -------------------------------------------------------------------- %
% single frame navigation
% Each figure has only one zoom mode object?
function movZoom(~,~,f)
fh = guidata(f);
btSt = getappdata(f,'btSt');
col = getappdata(f,'col');
if btSt.zoom==0
    btSt.zoom = 1;
    fh.zoom.BackgroundColor = [0.3 0.3 0.7];  % change icon color
    fh.pan.BackgroundColor = col;  % change icon color
    h = zoom;
    h.ActionPostCallback = {@mypostcallback,f};
    setAllowAxesZoom(h,fh.curve,0);  % zoom movie only, do not zoom the dff curve
    h.RightClickAction = 'InverseZoom';  % right click to zoom out
    h.Enable = 'on';
    h1 = pan;  % disable pan
    h1.Enable = 'off';
else
    btSt.zoom = 0;
    fh.zoom.BackgroundColor = col;
    h = zoom;
    h.Enable = 'off';
end
setappdata(f,'btSt',btSt);
end

function movPan(~,~,f)
fh = guidata(f);
btSt = getappdata(f,'btSt');
col = getappdata(f,'col');
if btSt.pan==0
    btSt.pan = 1;
    fh.pan.BackgroundColor = [0.3 0.3 0.7];  % change icon color
    fh.zoom.BackgroundColor = col;  % change icon color
    h = pan;
    h.ActionPostCallback = {@mypostcallback,f};
    setAllowAxesPan(h,fh.curve,0);  % zoom movie only, do not zoom the dff curve
    %h.RightClickAction = 'InverseZoom';  % right click to zoom out
    h.Enable = 'on';
    h1 = zoom;  % disable zoom
    h1.Enable = 'off';
else
    btSt.pan = 0;
    fh.pan.BackgroundColor = col;
    h = pan;
    h.Enable = 'off';
end
setappdata(f,'btSt',btSt);
end

function mypostcallback(~,evd,f)
scl = getappdata(f,'scl');
scl.wrg = evd.Axes.XLim;
scl.hrg = evd.Axes.YLim;
setappdata(f,'scl',scl);
end






