function zzshow(datIn,nameIn)
% GUI for curve visualization

if ~exist('nameIn','var')
    nameIn = '';
end

fh = figure('Visible','off','Position',[360,500,520,580],'WindowButtonDownFcn',@img_click,...
    'Name',nameIn,'NumberTitle','off');

hImg = axes('Units','pixels','Position',[10,70,500,500],'Tag','aImage');
hImg.XTick = [];hImg.YTick = [];

hReset = uicontrol(fh,'Style','pushbutton','String','Reset','Position',[10 40 40 20],...
    'HorizontalAlignment','left','Callback',@reset_view);
hTextTime = uicontrol(fh,'Style','text','String','Frame:','Position',[60 37 100 20],...
    'HorizontalAlignment','left','Tag','aTextTime');

% hTextTime = uicontrol(fh,'Style','text','String','Frame:','Position',[10 25 500 20],'Tag','aTextTime');
hImgSlider = uicontrol(fh,'Style','slider','Position',[10 10 500 25],'Tag','imageScroll','Callback',@img_slider);

hImg.Units = 'normalized';
hTextTime.Units = 'normalized';
hImgSlider.Units = 'normalized';
hReset.Units = 'normalized';

fh.Units = 'normalized';
xx = fh.Position;
xx(1:2) = [0.2,0.2];
fh.Position = xx;
fh.Visible = 'on';
data = guihandles(fh);

if exist('datIn','var')
    if length(size(datIn))==2
        vid0 = datIn;
        T = 1;
    end
    if length(size(datIn))==3
        if size(datIn,3)>3
            vid0 = datIn(:,:,1);
            T = size(datIn,3);
        end
        if size(datIn,3)==3
            vid0 = datIn;
            T = 1;
        end
    end
    if length(size(datIn))==4
        vid0 = datIn(:,:,:,1);
        T = size(datIn,4);
    end
    
    % vid0 = (vid0 - iL)/(iH-iL);
    imshow(vid0,'Parent',hImg);
    
    % change scroll bar
    data.imageScroll.Value = 1;
    data.imageScroll.Min = 1;
    data.imageScroll.Max = T;
    if T>1
        data.imageScroll.SliderStep = [1/(T-1),1/(T-1)*10];
    else
        data.imageScroll.Enable = 'off';
        %data.imageScroll.SliderStep = [1,1];
    end
    
    data.imgXLim = data.aImage.XLim;
    data.imgYLim = data.aImage.YLim;
    
    data.vid = datIn;
    data.iL = 0;
    data.iH = 1;
end
guidata(fh,data)

end

% selection callback
function img_click(hObj,eventdata)
data = guidata(hObj);

cursorPoint = data.aImage.CurrentPoint;
curX = round(cursorPoint(1,1));
curY = round(cursorPoint(1,2));
xLimits = data.aImage.XLim;
yLimits = data.aImage.YLim;

if (curX > min(xLimits) && curX < max(xLimits) && curY > min(yLimits) && curY < max(yLimits))
    n = round(data.imageScroll.Value);
    fprintf('(H,W,T): (%d,%d,%d) --',curY,curX,n)    
    %disp(['Cursor coordinates are (' num2str(curX) ', ' num2str(curY) ').']);    
    val = data.vid(curY,curX,n);
    fprintf('Value: %f\n',val);
    fprintf('lblMapS(%d,%d,%d)\n',curY,curX,n)
end
guidata(hObj,data);
end

% ----------------------------------------------------------- %
% controls callback
function img_slider(hObj, eventdata)
slideValue = get(hObj,'Value');
data = guidata(hObj);
xLimits = data.aImage.XLim;
yLimits = data.aImage.YLim;
if isfield(data,'vid')
    n = round(slideValue);
    if length(size(data.vid))==2
        vid0 = data.vid;
    end
    if length(size(data.vid))==3
        vid0 = data.vid(:,:,n);
    end
    if length(size(data.vid))==4
        vid0 = data.vid(:,:,:,n);
    end    
    imshow(vid0,'Parent',data.aImage);
    data.aImage.XLim = xLimits;
    data.aImage.YLim = yLimits;
    data.aTextTime.String = ['Frame: ',num2str(n)];
end
end

function reset_view(hObj, eventdata)
data = guidata(hObj);
data.aImage.XLim = data.imgXLim;
data.aImage.YLim = data.imgYLim;
end












