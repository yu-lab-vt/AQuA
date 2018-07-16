function addCon_proj(f,g)
% Welcome
bWel = uix.VButtonBox('Parent',g,'Spacing',20);
uicontrol(bWel,'String','New project','Callback',{@ui.proj.newProj,f});
uicontrol(bWel,'String','Load existing','Callback',{@ui.proj.loadExp,f});
bWel.ButtonSize = [150,50];

% New proj
bNew = uix.VBox('Parent',g,'Spacing',5,'Padding',5);
uix.Empty('Parent',bNew);
uicontrol('Parent',bNew,'Style','text','String','Movie (TIFF stack)','HorizontalAlignment','left');
bNew1 = uix.HBox('Parent',bNew);
% uicontrol('Parent',bNew,'Style','text','String','Output folder','HorizontalAlignment','left');
% bNew2 = uix.HBox('Parent',bNew);
uix.Empty('Parent',bNew);

% event detection: data settings
pDeProp = uix.Grid('Parent',bNew);
uicontrol(pDeProp,'Style','popupmenu','Tag','preset','Callback',{@ui.proj.updtPreset,f,0});
uicontrol(pDeProp,'Style','edit','String','1','Tag','tmpRes');
uicontrol(pDeProp,'Style','edit','String','1','Tag','spaRes');
uicontrol(pDeProp,'Style','edit','String','2','Tag','bdSpa');
uicontrol(pDeProp,'Style','text','String','Data type (presets)','HorizontalAlignment','left');
uicontrol(pDeProp,'Style','text','String','Temporal resolution: second per frame','HorizontalAlignment','left');
uicontrol(pDeProp,'Style','text','String','Spatial resolution: um per pixel','HorizontalAlignment','left');
uicontrol(pDeProp,'Style','text','String','Exclude pixels shorter than this distance to border','HorizontalAlignment','left');
pDeProp.Widths = [100,-1];
pDeProp.Heights = [20,20,20,20];
% pDeProp.Padding = 10;
pDeProp.Spacing = 8;

bload = uix.HButtonBox('Parent',bNew,'Spacing',25);
uicontrol(bload,'String','< Back','Callback',{@ui.proj.welcome,f});
uicontrol(bload,'String','Open','Callback',{@ui.proj.prep,f});
uicontrol(bload,'String','Load presets','Callback',{@ui.proj.updtPreset,f});
bload.ButtonSize = [110,20];
uix.Empty('Parent',bNew);
bNew.Heights = [-1,15,20,15,120,20,-1];
% bNew.Heights = [-1,15,20,15,20,15,120,20,-1];

uicontrol(bNew1,'Style','edit','Tag','fIn','HorizontalAlignment','left');
uicontrol(bNew1,'String','...','Callback',{@ui.proj.getInputFile,f});
bNew1.Widths = [-1,20];

end



