function addOne(~,~,f)
    
    fh = guidata(f);
    btSt = getappdata(f,'btSt');
    
    try
        evtNow = str2double(fh.toolsAddEvt.String);        
        lst = union(evtNow,btSt.evtMngrMsk);        
        btSt.evtMngrMsk = lst;
        setappdata(f,'btSt',btSt);
        ui.evt.evtMngrRefresh([],[],f);
        fts = getappdata(f,'fts');
        
        n0 = fts.curve.tBegin(evtNow);
        n1 = fts.curve.tEnd(evtNow);
        n = round((n0+n1)/2);        
        ui.movStep(f,n,[],1);
    catch
        msgbox('Invalid event ID')
    end
    
end
