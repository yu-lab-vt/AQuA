function prepInitUI(f,fh,opts,scl,~,stg,~)
    
    % layer panel
    gap0 = [0.01 0.1];
    fh.sldMin.Min = scl.min;
    fh.sldMin.Max = scl.max;
    fh.sldMin.SliderStep = gap0;
    fh.sldMin.Value = scl.min;
    
    fh.sldMax.Min = scl.min;
    fh.sldMax.Max = scl.max;
    fh.sldMax.SliderStep = gap0;
    fh.sldMax.Value = scl.max;
    
    fh.sldBri.Min = 0.1;
    fh.sldBri.Max = 10;
    fh.sldBri.SliderStep = gap0;
    fh.sldBri.Value = scl.bri;
    
    fh.sldMinOv.Min = 0;
    fh.sldMinOv.Max = 1;
    fh.sldMinOv.SliderStep = gap0;
    fh.sldMinOv.Value = scl.minOv;
    
    fh.sldMaxOv.Min = 0;
    fh.sldMaxOv.Max = 1;
    fh.sldMaxOv.SliderStep = gap0;
    fh.sldMaxOv.Value = scl.maxOv;
    
    fh.sldBriOv.Min = 0;
    fh.sldBriOv.Max = 1;
    fh.sldBriOv.SliderStep = gap0;
    fh.sldBriOv.Value = scl.briOv;
    
    % data panel
    fh.sldMov.Minimum = 1;
    fh.sldMov.Maximum = opts.sz(3);
    fh.sldMov.UnitIncrement = 1;
    fh.sldMov.BlockIncrement = 1;
    fh.sldMov.VisibleAmount = 0;
    fh.sldMov.Value = 1;
    
    % detection parameters
    fh.thrArScl.String = num2str(opts.thrARScl);
    fh.smoXY.String = num2str(opts.smoXY);
    fh.minSize.String = num2str(opts.minSize);
    
    fh.thrTWScl.String = num2str(opts.thrTWScl);
    fh.thrExtZ.String = num2str(opts.thrExtZ);
    
    fh.cRise.String = num2str(opts.cRise);
    fh.cDelay.String = num2str(opts.cDelay);
    fh.gtwSmo.String = num2str(opts.gtwSmo);
    
    fh.zThr.String = num2str(opts.zThr);
    
    fh.ignoreMerge.Value = 1*(opts.ignoreMerge>0);
    fh.mergeEventDiscon.String = num2str(opts.mergeEventDiscon);
    fh.mergeEventCorr.String = num2str(opts.mergeEventCorr);
    fh.mergeEventMaxTimeDif.String = num2str(opts.mergeEventMaxTimeDif);
    
    fh.extendEvtRe.Value = 1*(opts.extendEvtRe>0);
    
    fh.ignoreTau.Value = 1*(opts.ignoreTau>0);
    
    % color overlay
    ui.over.getColMap([],[],f);
    
    try
        % update overlay menu
        ui.over.updateOvFtMenu([],[],f);
        
        % User defined features
        ui.over.chgOv([],[],f,0);
        ui.over.chgOv([],[],f,1);
        ui.over.chgOv([],[],f,2);
        ui.evt.evtMngrRefresh([],[],f);
    catch
    end
    
    % resize GUI
    fh.g.Selection = 3;
    f.Resize = 'on';
    f.Position = getappdata(f,'guiMainSz');
    
    dbgx = getappdata(f,'dbg');
    if isempty(dbgx); dbgx=0; end        
    
    % UI visibility according to steps
    if stg.detect==0  % not started yet
        xx = fh.deOutTab.TabEnables;
        for ii=2:numel(xx)
            xx{ii} = 'off';
        end
        fh.deOutTab.TabEnables = xx;
        fh.deOutNext.Enable = 'off';
        fh.pFilter.Visible = 'off';
        fh.pExport.Visible = 'off';
        fh.pEvtMngr.Visible = 'off';
        fh.pSys.Visible = 'off';
    else  % finished
        ui.detect.filterInit([],[],f);
        evtLst = getappdata(f,'evtLst');
        if isempty(evtLst) && dbgx==0
            fh.bWkfl.Heights(2) = 0;  % never show detection part again
        end
    end
    fh.deOutTab.Selection = 1;
    fh.deOutBack.Visible = 'off';
    
    % show movie
    ui.movStep(f,1,[],1);
    
end





