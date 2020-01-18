function saveWaves(~,~,f)

    opts = getappdata(f,'opts');
    selpath = uigetdir(opts.filePath,'Choose output folder');
    path0 = [selpath,filesep,opts.fileName];
    
    if ~exist(path0,'file') && ~isempty(path0)
        mkdir(path0);    
    end
    
    path1 = [path0,filesep,'waves_whole_video'];
    path2 = [path0,filesep,'waves_event_duration'];
    if ~exist(path1,'file') && ~isempty(path1)
        mkdir(path1);    
    end
    if ~exist(path2,'file') && ~isempty(path2)
        mkdir(path2);    
    end
    
    
    btSt = getappdata(f,'btSt');
    favLst = btSt.evtMngrMsk;
    dffMat = getappdata(f,'dffMat');
    fts = getappdata(f,'fts');
    
    for i = 1:numel(favLst)
        evtID = favLst(i);
        curve = dffMat(evtID,:,1)';
        t0 = fts.curve.tBegin(evtID);
        t1 = fts.curve.tEnd(evtID);  
        
        Frame = [1:numel(curve)]';
        dff = curve;
        T = table(Frame,dff);
        writetable(T,[path1,filesep,'Evt',num2str(evtID),'.csv']);
        
        Frame = [t0:t1]';
        dff = curve(t0:t1);
        T = table(Frame,dff);
        writetable(T,[path2,filesep,'Evt',num2str(evtID),'.csv']);
    end  
end