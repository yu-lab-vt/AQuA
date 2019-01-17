function featurePlot(~,~,f)
    g = figure('Name','Features','MenuBar','none','Toolbar','none',...
        'NumberTitle','off','Visible','on','Position',[450,260,800,650]);
    fts = getappdata(f, 'fts');
    fh = guidata(f);
    col = fh.pan.BackgroundColor;
    ax = axes('Units','Pixels','Position',[50,150,700,450],'Tag','ax'); 
    btSt = getappdata(f,'btSt');
    xSel = btSt.filterMsk;
    fArea = fts.basic.area;
    fDFF = fts.curve.dffMax;
    fDur = fts.curve.width55;
    fPv = fts.curve.dffMaxPval;
    fDc = fts.curve.decayTau;
    
    
    setappdata(g,'f0',fArea);
    setappdata(g,'xSel',xSel);
    setappdata(g,'fArea',fArea);
    setappdata(g,'fDFF',fDFF);
    setappdata(g,'fDur',fDur);
    setappdata(g,'fPv',fPv);
    setappdata(g,'fDc',fDc);
    % component
    Bbox = uicontrol('String','Box Plot','Position',[50,50,80,20],'Callback',{@boxButton,g});
    Bhist = uicontrol('String','Histogram','Position',[200,50,80,20],'Callback',{@histButton,g});
    Filtered = uicontrol('String','Filtered Data','Position',[650,50,80,20],'Callback',{@filtered,g});
    Area = uicontrol('String','Area','Position',[50,20,80,20],'Callback',{@areaButton,g});
    Amp = uicontrol('String','dF/F','Position',[200,20,80,20],'Callback',{@ampButton,g});
    Duration = uicontrol('String','Duartion','Position',[350,20,80,20],'Callback',{@durButton,g});
    PValue = uicontrol('String','P value','Position',[500,20,80,20],'Callback',{@pvButton,g});
    DecayTau = uicontrol('String','DecayTau','Position',[650,20,80,20],'Callback',{@dcButton,g});
    gh = guihandles(g);
    gh.ax = ax;
    gh.area = Area;
    gh.amp = Amp;
    gh.duration = Duration;
    gh.pv = PValue;
    gh.decaytau = DecayTau;
    gh.col = col;
    gh.box = Bbox;
    gh.hist = Bhist;
    gh.filtered = Filtered;
    gh.plotType = 0;
    gh.fil = 0;
    guidata(g,gh);
    
    gh.box.BackgroundColor = [0.3 0.3 0.7];
    gh.box.ForegroundColor = [1 1 1];
    gh.area.BackgroundColor = [0.3 0.3 0.7];
    gh.area.ForegroundColor = [1 1 1];
    f0 = fArea;
    boxplot(ax,f0);
end
function boxButton(~,~,g)
    gh = guidata(g);
    ax = gh.ax;
    gh.plotType = 0;
    guidata(g,gh);
    gh.hist.BackgroundColor = gh.col;
    gh.hist.ForegroundColor = [0 0 0];
    gh.box.BackgroundColor = [0.3 0.3 0.7];
    gh.box.ForegroundColor = [1 1 1];
    gPlot(ax,g);
end
function filtered(~,~,g)
    gh = guidata(g);
    ax = gh.ax;
    if gh.fil==1
        gh.fil = 0;
        gh.filtered.BackgroundColor = gh.col;
        gh.filtered.ForegroundColor = [0 0 0];
    else
        gh.fil = 1;
        gh.filtered.BackgroundColor = [0.3 0.3 0.7];
        gh.filtered.ForegroundColor = [1 1 1];
    end
    guidata(g,gh);
    gPlot(ax,g);
end
function histButton(~,~,g)
    gh = guidata(g);
    ax = gh.ax;
    gh.plotType = 1;
    guidata(g,gh);
    gh.box.BackgroundColor = gh.col;
    gh.box.ForegroundColor = [0 0 0];
    gh.hist.BackgroundColor = [0.3 0.3 0.7];
    gh.hist.ForegroundColor = [1 1 1];
    gPlot(ax,g);
end
function areaButton(~,~,g)
    gh = guidata(g);
    ax = gh.ax;
    clearButton(g);
    f0 = getappdata(g,'fArea');
    setappdata(g,'f0',f0);
    gPlot(ax,g);
    xlabel('Area');
    ylabel('Value');
    gh.area.BackgroundColor = [0.3 0.3 0.7];
    gh.area.ForegroundColor = [1 1 1];
end
function ampButton(~,~,g)
    gh = guidata(g);
    ax = gh.ax;
    clearButton(g);
    f0 = getappdata(g,'fDFF');
    setappdata(g,'f0',f0);
    gPlot(ax,g);
    xlabel('dF/F');
    ylabel('Value');
    gh.amp.BackgroundColor = [0.3 0.3 0.7];
    gh.amp.ForegroundColor = [1 1 1];
end
function durButton(~,~,g)
    gh = guidata(g);
    ax = gh.ax;
    clearButton(g);
    f0 = getappdata(g,'fDur');
    setappdata(g,'f0',f0);
    gPlot(ax,g);
    xlabel('Duration');
    ylabel('Value');
    gh.duration.BackgroundColor = [0.3 0.3 0.7];
    gh.duration.ForegroundColor = [1 1 1];
end
function pvButton(~,~,g)
    gh = guidata(g);
    ax = gh.ax;
    clearButton(g);
    f0 = getappdata(g,'fPv');
    setappdata(g,'f0',f0);
    gPlot(ax,g);
    xlabel('Duration');
    ylabel('Value');
    gh.pv.BackgroundColor = [0.3 0.3 0.7];
    gh.pv.ForegroundColor = [1 1 1];
end
function dcButton(~,~,g)
    gh = guidata(g);
    ax = gh.ax;
    clearButton(g);
    f0 = getappdata(g,'fDc');
    setappdata(g,'f0',f0);
    gPlot(ax,g);
    xlabel('DecayTau');
    ylabel('Value');
    gh.decaytau.BackgroundColor = [0.3 0.3 0.7];
    gh.decaytau.ForegroundColor = [1 1 1];
end
function clearButton(g)
    gh = guidata(g);
    
    gh.area.BackgroundColor = gh.col;
    gh.area.ForegroundColor = [0 0 0];
    gh.amp.BackgroundColor = gh.col;
    gh.amp.ForegroundColor = [0 0 0];
    gh.duration.BackgroundColor = gh.col;
    gh.duration.ForegroundColor = [0 0 0];
    gh.pv.BackgroundColor = gh.col;
    gh.pv.ForegroundColor = [0 0 0];
    gh.decaytau.BackgroundColor = gh.col;
    gh.decaytau.ForegroundColor = [0 0 0];
end
function gPlot(ax,g)
    gh = guidata(g);
    f0 = getappdata(g,'f0');
    
    if gh.fil==1
       xSel = getappdata(g,'xSel');
       f0 = f0(xSel>0);
    end
    
    
    if gh.plotType==0
        boxplot(ax,f0);
    else
        hist(ax,f0);
    end
    xlabel('Duration');
    ylabel('Value');
end
