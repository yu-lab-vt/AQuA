function im1 = addCon_datMsk(f,pDat)
% masks image view ***********

% top level panels
bDat = uix.VBox('Parent',pDat,'Spacing',10,'Padding',3);
% pImgTool = uix.HBox('Parent',bDat,'Spacing',10);  % zoom in/out, pan
uix.Empty('Parent',bDat);
pMovTop = uix.CardPanel('Parent',bDat);  % movies
uix.Empty('Parent',bDat);
bDat.Heights = [10,-1,10];

% single movie view
bMov1Top = uix.VBox('Parent',pMovTop);
pMov1 = axes('Parent',bMov1Top,'ActivePositionProperty','Position','Tag','imgMsk');
pMov1.XTick = [];
pMov1.YTick = [];
d0 = ones(100,100,3);
pMov1.XLim = [1 100];
pMov1.YLim = [1 100];
im1 = image(pMov1,'CData',flipud(d0));
% text(pMov1,10,60,'Open a mask','FontSize',24);
% text(pMov1,30,50,'or get from current movie','FontSize',24);
im1.CDataMapping = 'scaled';
pMov1.DataAspectRatio = [1 1 1];

% % image tools
% uix.Empty('Parent',pImgTool);
% uicontrol(pImgTool,'String','Pan','Tag','pan','Callback',{@ui.msk.movPan,f});
% uicontrol(pImgTool,'String','Zoom','Tag','zoom','Callback',{@ui.msk.movZoom,f});
% uix.Empty('Parent',pImgTool);
% pImgTool.Widths = [10,60,60,-1];

end

