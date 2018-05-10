function saveMsk(~,~,f,op)
    
    fh = guidata(f);
    
    if op==1
        fh.g.Selection = 3;
        return
    end
    
    bd = getappdata(f,'bd');
    if isKey(bd,'maskLst')
        bdMsk = bd('maskLst');
    else
        bdMsk = [];
    end
    
    if isempty(bdMsk)
        fh.g.Selection = 3;
        return
    end
    
    % combine masks
    opReg = fh.saveMskRegOp.Value;
    opLmk = fh.saveMskLmkOp.Value;
    regMskAll = [];
    lmkMskAll = [];
    minRegSz = 1e8;
    minLmkSz = 1e8;
    for ii=1:numel(bdMsk)
        rr0 = bdMsk{ii};
        if strcmp(rr0.type,'region')
            minRegSz = min(minRegSz,rr0.minSz);
            if isempty(regMskAll)
                regMskAll = rr0.mask;
                continue
            end
            if opReg==1
                regMskAll = regMskAll.*rr0.mask;
            else
                regMskAll = regMskAll+rr0.mask;
            end
        else
            minLmkSz = min(minLmkSz,rr0.minSz);
            if isempty(lmkMskAll)
                lmkMskAll = rr0.mask;
                continue
            end
            if opLmk==1
                lmkMskAll = lmkMskAll.*rr0.mask;
            else
                lmkMskAll = lmkMskAll+rr0.mask;
            end
        end
    end
    
    % get regions and landmarks data structure
    % !! do not allow holes
    
    %[H,W] = size(regMskAll);
    regA = bwareaopen(regMskAll>0,round(minRegSz/4));
    lmkA = bwareaopen(lmkMskAll>0,round(minLmkSz/4));
    
    ccReg = bwboundaries(regA);
    ccLmk = bwboundaries(lmkA);
    
    % clear previous regions from masks
    regAll = bd('cell');
    for ii=1:numel(regAll)
        tmp = regAll{ii};
        if numel(tmp)>2 && strcmp(tmp{3},'auto')
            regAll{ii} = [];
        end        
    end    
    regAll = regAll(~cellfun(@isempty,regAll));
    
    lmkAll = bd('landmk');
    for ii=1:numel(lmkAll)
        tmp = lmkAll{ii};
        if numel(tmp)>2 && strcmp(tmp{3},'auto')
            lmkAll{ii} = [];
        end        
    end
    lmkAll = lmkAll(~cellfun(@isempty,lmkAll));
    
    % add new
    nNow = numel(regAll);
    for ii=1:numel(ccReg)
        tmp = [];
        xx = ccReg{ii};
        tmp{1} = [xx(:,2),xx(:,1)];
        tmp{3} = 'auto';
        regAll{nNow+ii} = tmp;
    end
    bd('cell') = regAll;    
    
    nNow = numel(lmkAll);
    for ii=1:numel(ccLmk)
        tmp = [];
        xx = ccLmk{ii};
        tmp{1} = [xx(:,2),xx(:,1)];
        tmp{3} = 'auto';
        lmkAll{nNow+ii} = tmp;
    end
    bd('landmk') = lmkAll;
    
    setappdata(f,'bd',bd);
    fh.g.Selection = 3;
    
    ui.movStep(f,[],[],1);
    
end

