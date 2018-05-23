function readMsk(~,~,f,srcType,mskType,initThr)
    
    % read mask data
    btSt = getappdata(f,'btSt');
    if isfield(btSt,'mskFolder') && ~isempty(btSt.mskFolder)
        p0 = btSt.mskFolder;
    else
        p0 = '.';
    end
    if ~exist('initThr','var')
        initThr = [];
    end
    
    if strcmp(srcType,'file')
        [FileName,PathName] = uigetfile({'*.tif','*.tiff'},'Choose movie',p0);
        if ~isempty(FileName) && ~isnumeric(FileName)
            fIn = [PathName,FileName];
        else
            return
        end
        dat = io.readTiffSeq(fIn,1);
        ffName = FileName;
    elseif strcmp(srcType,'folder')
        PathName = uigetdir(p0,'Stack folder');
        if ~isempty(PathName) && ~isnumeric(PathName)
            dd = dir([PathName,filesep,'*.tif']);
            if isempty(dd)
                return
            end
            ff = waitbar(0,'Reading...');
            dat = double(imread([PathName,filesep,dd(1).name]));
            for ii=2:numel(dd)
                waitbar(ii/numel(dd),ff);
                dat = dat + double(imread([PathName,filesep,dd(ii).name]));
            end
            delete(ff);
            dat = dat/numel(dd);
            %ffName = dd(1).name;
            xx = strsplit(PathName,filesep);
            ffName = [xx{end},'-folder'];
        else
            return
        end
    elseif strcmp(srcType,'self')
        PathName = p0;
        dat = getappdata(f,'datOrg');
        ffName = 'Project data';
    else
        return
    end
    
    btSt.mskFolder = PathName;
    setappdata(f,'btSt',btSt);
    
    % mean projection
    dat = squeeze(dat);
    if numel(size(dat))==3
        datAvg = mean(dat,3);
    else
        datAvg = dat;
    end
    datAvg = datAvg/nanmax(datAvg(:));
    
    % adjust contrast
    % thresholding and sizes of components
    if isempty(initThr)
        datAvg = imadjust(datAvg,stretchlim(datAvg,0.001));
        datLevel = graythresh(datAvg);
    else
        datLevel = initThr;
    end
    [H,W] = size(datAvg);
    
    % mask object
    rr = [];
    rr.name = ffName;
    rr.datAvg = datAvg;
    rr.type = mskType;
    rr.thr = datLevel;
    rr.minSz = 1;
    rr.maxSz = H*W;
    rr.mask = zeros(size(datAvg));
    
    bd = getappdata(f,'bd');
    if ~isempty(bd) && bd.isKey('maskLst')
        bdMsk = bd('maskLst');
    else
        bdMsk = [];
    end
    bdMsk{end+1} = rr;
    bd('maskLst') = bdMsk;
    setappdata(f,'bd',bd);
    
    % update mask list, image view and slider values
    ui.msk.mskLstViewer([],[],f,'refresh');
    
end






