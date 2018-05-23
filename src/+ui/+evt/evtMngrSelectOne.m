function evtMngrSelectOne(~,evtDat,f)
    
    try
        idxNow = evtDat.Indices(1,1);
    catch
        return
    end
    
    if isempty(idxNow) || idxNow==0
        return
    end    
    
    fh = guidata(f);
    tb = fh.evtTable;
    dat = tb.Data;
    for ii=1:size(dat,1)
        if ii==idxNow
            dat{ii,1} = 1;
        else
            dat{ii,1} = 0;
        end
    end
    evtNow = dat{idxNow,2};

    % show curve
    ui.evt.curveRefresh([],[],f,evtNow);
    
    % jump to frame
    fts = getappdata(f,'fts');
    n0 = fts.curve.tBegin(evtNow);
    n1 = fts.curve.tEnd(evtNow);
    n = round((n0+n1)/2);
    ui.movStep(f,n);
    fh.sldMov.Value = n;
    
end



