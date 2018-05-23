function addDetectTab(f,pDeOut)
    % addDetectTab adds event detection pipeline panels in tabs    
    h = cell(0);
    
    % top
    bDeOut = uix.VBox('Parent',pDeOut,'Padding',3,'Spacing',3);
    uix.Empty('Parent',bDeOut);
    deOutTab = uix.TabPanel('Parent',bDeOut,'Tag','deOutTab');
    deOutCon = uix.HButtonBox('Parent',bDeOut,'Spacing',10);
    uix.Empty('Parent',bDeOut);
    bDeOut.Heights = [-1,150,25,-1];
    
    % tabs
    pAct = uix.Panel('Parent',deOutTab,'Title','Active voxels','Tag','pAct');
    pSp = uix.Panel('Parent',deOutTab,'Title','Super voxels','Tag','pSp');
    pEvt = uix.Panel('Parent',deOutTab,'Title','Super events and events','Tag','pEvt');
    pZs = uix.Panel('Parent',deOutTab,'Title','False positive control','Tag','pZs');
    pMerge = uix.Panel('Parent',deOutTab,'Title','Merging','Tag','pMerge');
    pEvtRe = uix.Panel('Parent',deOutTab,'Title','Reconstruct after merging','Tag','pEvtRe');
    pFea = uix.Panel('Parent',deOutTab,'Title','Feature extraction','Tag','pFea');
    deOutTab.TabTitles = {'Signal','Voxel','Event','Clean','Merge','Recon','Fea'};
    deOutTab.TabWidth = 33;
    deOutTab.SelectionChangedFcn = {@ui.detect.flow,f,'chg'};
    
    % controls
    pBack = uicontrol(deOutCon,'String','Back','Tag','deOutBack');
    pRun = uicontrol(deOutCon,'String','Run','Tag','deOutRun');
    pNext = uicontrol(deOutCon,'String','Next','Tag','deOutNext');
    pBack.Callback = {@ui.detect.flow,f,'back'};
    pRun.Callback = {@ui.detect.flow,f,'run'};
    pNext.Callback = {@ui.detect.flow,f,'next'};
    deOutCon.ButtonSize = [100,20];
    
    % event detection: active voxels
    bAct = uix.VBox('Parent',pAct);
    gAct = uix.Grid('Parent',bAct,'Padding',10,'Spacing',8);
    uicontrol(gAct,'Style','edit','String','2','Tag','thrArScl');
    uicontrol(gAct,'Style','edit','String','0.5','Tag','smoXY');
    uicontrol(gAct,'Style','edit','String','8','Tag','minSize');
    h{end+1} = uicontrol(gAct,'Style','text','String','Intensity threshold scaling factor');
    h{end+1} = uicontrol(gAct,'Style','text','String','Smoothing (sigma)');
    h{end+1} = uicontrol(gAct,'Style','text','String','Minimum size (pixels)');
    gAct.Widths = [50,-1]; gAct.Heights = [15,15,15];
    
    % event detection: superpixels and rising time
    bPhase = uix.VBox('Parent',pSp);
    gPhase = uix.Grid('Parent',bPhase,'Padding',10,'Spacing',8);
    uicontrol(gPhase,'Style','edit','String','2','Tag','thrTWScl');
    uicontrol(gPhase,'Style','edit','String','1','Tag','thrExtZ');
    h{end+1} = uicontrol(gPhase,'Style','text','String','Temporal cut threshold');
    h{end+1} = uicontrol(gPhase,'Style','text','String','Growing z threshold');
    gPhase.Widths = [50,-1]; gPhase.Heights = [15,15];
    
    % event detection: events
    bEvt = uix.VBox('Parent',pEvt);
    gEvt = uix.Grid('Parent',bEvt,'Padding',10,'Spacing',8);
    uicontrol(gEvt,'Style','edit','String','2','Tag','cRise');
    uicontrol(gEvt,'Style','edit','String','0.5','Tag','cDelay');
    uicontrol(gEvt,'Style','edit','String','0.1','Tag','gtwSmo');
    h{end+1} = uicontrol(gEvt,'Style','text','String','Rising time uncertainty');
    h{end+1} = uicontrol(gEvt,'Style','text','String','Slowest delay in propagation');
    h{end+1} = uicontrol(gEvt,'Style','text','String','Propagation smoothness');
    gEvt.Widths = [50,-1]; gEvt.Heights = [15,15,15];
    
    % remove false positives
    bZs = uix.VBox('Parent',pZs);
    gZs = uix.Grid('Parent',bZs,'Padding',10,'Spacing',8);
    uicontrol(gZs,'Style','edit','String','2','Tag','zThr');
    h{end+1} = uicontrol(gZs,'Style','text','String','Z score threshold');
    gZs.Widths = [50,-1]; gZs.Heights = 15;
    
    % merging
    bMerge = uix.VBox('Parent',pMerge,'Padding',10);
    uicontrol(bMerge,'Style','checkbox','String','Ignore merging',...
        'Value',0,'Tag','ignoreMerge');
    gMerge = uix.Grid('Parent',bMerge,'Padding',10,'Spacing',8);
    uicontrol(gMerge,'Style','edit','String','2','Tag','mergeEventDiscon');
    uicontrol(gMerge,'Style','edit','String','2','Tag','mergeEventCorr');
    uicontrol(gMerge,'Style','edit','String','2','Tag','mergeEventMaxTimeDif');
    h{end+1} = uicontrol(gMerge,'Style','text','String','Maximum distance');
    h{end+1} = uicontrol(gMerge,'Style','text','String','Minimum correlation');
    h{end+1} = uicontrol(gMerge,'Style','text','String','Maximum time difference');
    gMerge.Widths = [50,-1]; gMerge.Heights = [15,15,15];
    bMerge.Heights = [20,-1];
    
    % Re-align
    bEvtRe = uix.VBox('Parent',pEvtRe,'Padding',10);
    uicontrol(bEvtRe,'Style','checkbox','String','Temporally extend events',...
        'Value',1,'Tag','extendEvtRe');
    uix.Empty('Parent',bEvtRe);
    bEvtRe.Heights = [20,-1];
    
    % Extract feature
    bFea = uix.VBox('Parent',pFea,'Padding',10);
    uicontrol(bFea,'Style','checkbox','String','Ignore delay Tau',...
        'Value',1,'Tag','ignoreTau');
    uix.Empty('Parent',bFea);
    bFea.Heights = [20,-1];
    
    for ii=1:numel(h)
        h00 = h{ii};
        h00.HorizontalAlignment = 'left';
    end    
end

