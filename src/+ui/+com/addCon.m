function addCon(f,dbg)

% top level panels
g = uix.CardPanel('Parent',f,'Tag','g');
ui.com.addCon_proj(f,g);
bMain = uix.HBox('Parent',g,'Spacing',15,'Padding',5);
bMsk = uix.HBox('Parent',g,'Spacing',15,'Padding',5);
g.Selection = 1;

% main UI
pWkfl = uix.CardPanel('Parent',bMain);
pDat = uix.Panel('Parent',bMain);
pTool = uix.CardPanel('Parent',bMain);
bMain.Widths = [300 -1 300];

ui.com.addCon_wkfl(f,pWkfl);
ims = ui.com.addCon_dat(f,pDat);
ui.com.addCon_tools(f,pTool);

% mask builder UI
pWkflMsk = uix.CardPanel('Parent',bMsk);
pDatMsk = uix.Panel('Parent',bMsk);
pToolMsk = uix.CardPanel('Parent',bMsk);
bMsk.Widths = [300 -1 300];

ui.msk.addCon_wkflMsk(f,pWkflMsk);
imsMsk = ui.msk.addCon_datMsk(f,pDatMsk);
ui.msk.addCon_toolsMsk(f,pToolMsk);

% default GUI settings
fh = guihandles(f);
fh.ims = ims;
fh.imsMsk = imsMsk;
guidata(f,fh);
col = fh.pan.BackgroundColor;
setappdata(f,'col',col);

Pix_SS = get(0,'screensize');
h0 = Pix_SS(4)+22; w0 = Pix_SS(3);  % 50 is taskbar size

btSt = ui.proj.initStates();

setappdata(f,'btSt',btSt);
setappdata(f,'guiWelcomeSz',[w0/2-200,h0/2-150,400,300]);
setappdata(f,'guiMainSz',[w0/2-700 h0/2-400 1400 900]);
% setappdata(f,'guiMainSz',[90 90 1400 850]);

f.Position = getappdata(f,'guiWelcomeSz');

% debug UI
if dbg>0
    [ov,bd,scl,~] = ui.proj.prepInitUIStruct();
    setappdata(f,'ov',ov);
    setappdata(f,'bd',bd);
    setappdata(f,'scl',scl);
end
if dbg==1
    fh.g.Selection = 3;    
end
if dbg==2
    fh.g.Selection = 4;
end
if dbg>0
    f.Position = [w0/2-700 h0/2-400 1400 800];
%     warning('off','all');
%     try
%         pause(0.00001);
%         frame_h = get(f,'JavaFrame');
%         set(frame_h,'Maximized',1);
%     catch        
%     end
%     warning('on','all');
end

end





