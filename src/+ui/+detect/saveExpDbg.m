function res = saveExpDbg(~,~,f,e)
    % saveExp save experiment (and export results)
    
    fts = getappdata(f,'fts');
    
    % gather results
    
    vSave0 = {...  % basic variables for results analysis
        'opts','scl','btSt','ov','bd','datOrg','evt','fts','dffMat','dMat',...
        'riseLst','featureTable','userFeatures'...
        };
    vSave1 = {...  % extra variables for event detection
        'arLst','lmLoc','svLst','riseX','riseLstAll','evtLstAll','ftsLstAll',...
        'dffMatAll','datRAll','evtLstFilterZ','dffMatFilterZ','tBeginFilterZ',...
        'riseLstFilterZ','evtLstMerge','dF'...
        };
    vSave = [vSave0,vSave1];
    
    res = [];
    for ii=1:numel(vSave)
        v0 = vSave{ii};
        res.(v0) = getappdata(f,v0);
    end
    
    % filter features and curves
    try
        ov = getappdata(f,'ov');
        ov0 = ov('Events');
        xSel = ov0.sel;
        
        res.ftsFilter = util.filterFields(fts,xSel);
        res.evtFilter = res.evt(xSel);
        res.dffMatFilter = res.dffMat(xSel,:,:);
        if ~isempty(res.dMat)
            res.dMatFilter = res.dMat(xSel,:,:);
        end
        if ~isempty(res.riseLst)  % rising map is for super events
            res.riseLstFilter = res.riseLst(xSel);
        end
        res.evtSelectedList = find(xSel>0);
    catch        
    end
    
    % save raw movie with 8 or 16 bits to save space
    res.opts.bitNum = 16;
    res.maxVal = nanmax(res.datOrg(:));
    res.datOrg = res.datOrg/res.maxVal;
    dat1 = res.datOrg*(2^res.opts.bitNum-1);
    res.datOrg = uint16(dat1);
    
    res.stg.post = 1;
    res.stg.detect = 1;
    res.dbg = 1;
    res.error = e;
    
    save('debug.mat','res','-v7.3');
    
    
end







