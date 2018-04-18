function prep(~,~,f,op,res)
% read data or load experiment
% op
% 0: new project
% 1: load project or saved results
% 2: load from workspace

fprintf('Loading ...\n');

cfgFile = './cfg/uicfg.mat';
if ~exist(cfgFile,'file')
    cfg0 = [];
else
    cfg0 = load(cfgFile);
end

if ~exist('op','var') || isempty(op)
    op = 0;
end

fh = guidata(f);

% new project
if op==0
    preset = fh.preset.Value;
    opts = util.parseParam(preset,0,'./cfg/parameters1.xlsx');
    opts.preset = preset;
    
    % read user input
    try
        opts.frameRate = str2double(fh.tmpRes.String);
        opts.spatialRes = str2double(fh.spaRes.String);
        opts.regMaskGap = str2double(fh.bdSpa.String);
    catch
        msgbox('Invalid input');
        return
    end
    
    try
        pf0 = fh.fIn.String;
        [filepath,name,ext] = fileparts(pf0);
        %opts.outPath = fh.pOut.String;
        [dat,dF,opts,H,W,T] = burst.prep1(filepath,[name,ext],[],opts); %#ok<ASGLU>
        
        % save folder
        cfg0.file = pf0;
        save(cfgFile,'cfg0');
    catch
        msgbox('Fail to load file');
        return
    end
    
    % UI data structure
    [ov,bd,scl,btSt] = ui.prepInitUIStruct(dat,opts); %#ok<ASGLU>
    
    % data and settings
    vBasic = {'opts','scl','btSt','ov','bd','dat','evt','fts','dffMat','dMat',...
        'dF','datSmo','lmLocR','lmLoc','lblMapS','riseMap','arLst'};
    for ii=1:numel(vBasic)
        v0 = vBasic{ii};
        if exist(v0,'var')
            setappdata(f,v0,eval(v0));
        else
            setappdata(f,v0,[]);
        end
    end
    stg = [];
    stg.detect = 0;
    stg.post = 0;
end

% read existing project or mat file
if op>0
    if op==1
        fexp = getappdata(f,'fexp');
        tmp = load(fexp);
        res = tmp.res;
        
        [p00,~,~] = fileparts(fexp);
        cfg0.outPath = p00;
        save(cfgFile,'cfg0');
    end
    
    % int to double
    res.dat = double(res.dat)/(2^res.opts.bitNum-1);
    
    if ~isfield(res,'scl')
        [~,res.bd,res.scl,res.btSt] = ui.prepInitUIStruct(res.dat,res.opts);
        res.stg = [];
        res.stg.detect = 0;
        res.stg.post = 1;
    else
        [~,~,res.scl] = ui.prepInitUIStruct(res.dat,res.opts);
    end
    
    res.btSt.overlayDatSel = 'Events';
    res.btSt.overlayColorSel = 'Random';
    
    opts = res.opts;
    scl = res.scl;
    stg = res.stg;
    ov = res.ov;
    
    fns = fieldnames(res);
    for ii=1:numel(fns)
        f00 = fns{ii};
        setappdata(f,f00,res.(f00));
    end
end

% UI
ui.prepInitUI(f,fh,opts,scl,ov,stg,op);

fprintf('Done ...\n');

end











