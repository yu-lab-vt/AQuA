function addCon(f,dbg)

% top level panels
g = uix.CardPanel('Parent',f,'Tag','g');
ui.com.addCon_proj(f,g);
bMain = uix.HBox('Parent',g,'Spacing',15,'Padding',5);
g.Selection = 1;

% main UI
pWkfl = uix.CardPanel('Parent',bMain);
pDat = uix.CardPanel('Parent',bMain);
pTool = uix.CardPanel('Parent',bMain);
bMain.Widths = [300 -1 350];
% bMain.MinimumWidths = [300,300,400];

ui.com.addCon_wkfl(f,pWkfl);
[im1,im2a,im2b] = ui.com.addCon_dat(f,pDat);
ui.com.addCon_tools(f,pTool);

fh = guihandles(f);
fh.im = im1;
fh.im2a = im2a;
fh.im2b = im2b;
guidata(f,fh);
col = fh.pan.BackgroundColor;
setappdata(f,'col',col);

% default GUI settings
btSt = ui.proj.initStates();
setappdata(f,'btSt',btSt);

if dbg
    fh.g.Selection = 3;
    f.Position = [90 90 1400 850];
end

end

