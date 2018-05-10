function addCon_toolsMsk(f,pTool)
% masks ***********

% tools panels
bTool = uix.VBox('Parent',pTool,'Spacing',10);
% pLayer = uix.BoxPanel('Parent',bTool,'Title','Image brightness/contrast');
pThr = uix.BoxPanel('Parent',bTool,'Title','Foreground detection');
uix.Empty('Parent',bTool);
bTool.Heights = [150,-1];
% bTool.Heights = [150,150,-1];

% % movie
% bMovBri = uix.VBox('Parent',pLayer,'Spacing',5,'Padding',3);
% uicontrol(bMovBri,'Style','text','String','Min','HorizontalAlignment','left');
% uicontrol(bMovBri,'Style','slider','Tag','sldMin','Callback',{@ui.msk.adjMov,f});
% uicontrol(bMovBri,'Style','text','String','Max','HorizontalAlignment','left');
% uicontrol(bMovBri,'Style','slider','Tag','sldMax','Callback',{@ui.msk.adjMov,f});
% uicontrol(bMovBri,'Style','text','String','Brightness','HorizontalAlignment','left');
% uicontrol(bMovBri,'Style','slider','Tag','sldBri','Callback',{@ui.msk.adjMov,f});
% bMovBri.Heights = [15,15,15,15,15,15];

% thresholding
bMovThr = uix.VBox('Parent',pThr,'Spacing',5,'Padding',3);
uicontrol(bMovThr,'Style','text','String','Intensity threshold','HorizontalAlignment','left');
uicontrol(bMovThr,'Style','slider','Tag','sldMskThr','Callback',{@ui.msk.adjMov,f});
uicontrol(bMovThr,'Style','text','String','Size (min)','HorizontalAlignment','left');
uicontrol(bMovThr,'Style','slider','Tag','sldMskMinSz','Callback',{@ui.msk.adjMov,f});
uicontrol(bMovThr,'Style','text','String','Size (max)','HorizontalAlignment','left');
uicontrol(bMovThr,'Style','slider','Tag','sldMskMaxSz','Callback',{@ui.msk.adjMov,f});
% bMovThrBut = uix.HButtonBox('Parent',bMovThr,'ButtonSize',[120,20]);
% uicontrol(bMovThrBut,'String','Apply','Callback',{@ui.msk.applyMask,f});
bMovThr.Heights = [15,15,15,15,15,15];
% bMovThr.Heights = [15,15,15,15,15,15,20];

end








