function mskLstViewer(~,evtDat,f,op)
    % op: refresh, remove, select
    
    fh = guidata(f);
    tb = fh.mskTable;
    
    bd = getappdata(f,'bd');
    bdMsk = bd('maskLst');
    stg = 0;
    
    % t.ColumnName = {'','Mask name','Type'};
    % rr.name = ffName;
    % rr.datAvg = datAvg;
    % rr.type = mskType;
    
    if strcmp(op,'refresh')
        nMsk = numel(bdMsk);
        dat = cell(nMsk,3);
        for ii=1:nMsk
            rr = bdMsk{ii};
            dat{ii,1} = false;
            dat{ii,2} = rr.name;
            dat{ii,3} = rr.type;
        end
        dat{nMsk,1} = true;
        tb.Data = dat;
        rr = bdMsk{end};
    end
    
    if strcmp(op,'select')
        evtInd = evtDat.Indices;
        if isempty(evtInd)
            return
        end
        idx = evtInd(1,1);
        dat = tb.Data;
        for ii=1:size(dat,1)
            dat{ii,1} = false;
        end
        dat{idx,1} = true;
        tb.Data = dat;
        rr = bdMsk{idx};
        stg = 1;
    end
    
    if strcmp(op,'remove')
        dat = tb.Data;
        if isempty(dat)
            return
        end
        if size(dat,1)==1
            dat = zeros(0,3);
            tb.Data = dat;
            bd('maskLst') = [];
            im = fh.imsMsk;
            d0 = ones(100,100,3);
            im.CData = d0;
            fh.imgMsk.XLim = [1 100];
            fh.imgMsk.YLim = [1 100];
            setappdata(f,'bd',bd);
            return
        else
            idx = cell2mat(dat(:,1));
            dat = dat(~idx,:);
            dat{1,1} = true;
            tb.Data = dat;
            bdMsk = bdMsk(~idx);
            rr = bdMsk{1};
            bd('maskLst') = bdMsk;
            setappdata(f,'bd',bd);
        end
    end
    
    ui.msk.updtMskSld([],[],f,rr);
    ui.msk.viewImgMsk([],[],f,stg);  % update image
    
end





