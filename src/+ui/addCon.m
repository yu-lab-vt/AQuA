function im = addCon(f)

% top level panels
g = uix.CardPanel('Parent',f,'Tag','g');
ui.addCon_proj(f,g);
bMain = uix.HBoxFlex('Parent',g,'Spacing',15,'Padding',5);
g.Selection = 1;

% main UI
pWkfl = uix.CardPanel('Parent',bMain);
pDat = uix.CardPanel('Parent',bMain);
pTool = uix.CardPanel('Parent',bMain);
bMain.Widths = [300 -1 300];
bMain.MinimumWidths = [300,300,300];

ui.addCon_wkfl(f,pWkfl);
im = ui.addCon_dat(f,pDat);
ui.addCon_tools(f,pTool);

end

