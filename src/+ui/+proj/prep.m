function prep(~,~,f,op,res)
% read data or load experiment
% op
% 0: new project
% 1: load project or saved results
% 2: load from workspace
% FIXME: udpate GUI settings (btSt), instead of re-build it

fprintf('Loading ...\n');
ff = waitbar(0,'Loading ...');

% cfgFile = 'uicfg.mat';
% if ~exist(cfgFile,'file')
%     cfg0 = [];
% else
%     cfg0 = load(cfgFile);
% end

if ~exist('op','var') || isempty(op)
    op = 0;
end

fh = guidata(f);

% new project
if op==0
    preset = fh.preset.Value;
    opts = util.parseParam(preset,0);
    opts.preset = preset;
    
    % read user input
    try
        % if ~strcmp(fh.tmpRes.String,'As preset')
            opts.frameRate = str2double(fh.tmpRes.String);
        % end
        % if ~strcmp(fh.spaRes.String,'As preset')
            opts.spatialRes = str2double(fh.spaRes.String);
        % end
        % if ~strcmp(fh.bdSpa.String,'As preset')
            opts.regMaskGap = str2double(fh.bdSpa.String);
        % end
    catch
        % msgbox('Invalid input');
        % return
    end
    
    try
        pf0 = fh.fIn.String;
        [filepath,name,ext] = fileparts(pf0);
        [datOrg,opts] = burst.prep1(filepath,[name,ext],[],opts,ff);
        %cfg0.file = pf0;  % save folder
        %save(cfgFile,'cfg0');
    catch
        msgbox('Fail to load file');
        return
    end
    
    maxPro = max(datOrg,[],3);
    fh.maxPro = maxPro;
    fh.showcurves = [];
    guidata(f,fh);
    
    % UI data structure
    [ov,bd,scl,btSt] = ui.proj.prepInitUIStruct(datOrg,opts); %#ok<ASGLU>
    
    % data and settings
    vBasic = {'opts','scl','btSt','ov','bd','datOrg'};
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
end

% read existing project or mat file
if op>0
    if op==1
        fexp = getappdata(f,'fexp');
        tmp = load(fexp);
        res = tmp.res;
        
        % [p00,~,~] = fileparts(fexp);
        % cfg0.outPath = p00;
        % save(cfgFile,'cfg0');
    end
    
    % rescale int8 to [0,1] double
    % dat is for detection, datOrg for viewing
    %res.dat = double(res.dat)/(2^res.opts.bitNum-1);
    if isfield(res,'datOrg')
        res.datOrg = double(res.datOrg)/(2^res.opts.bitNum-1);
    else
        res.datOrg = double(res.dat);
    end
    if isfield(res,'maxVal')
        res.datOrg = res.datOrg*res.maxVal;
    end
    
    dat = res.datOrg;
    if res.opts.smoXY>0
        for tt=1:size(dat,3)
            dat(:,:,tt) = imgaussfilt(dat(:,:,tt),res.opts.smoXY);
        end
    end
    res.dat = dat;
    
    waitbar(0.5,ff);
    
    if ~isfield(res,'scl')
        [~,res.bd,res.scl,res.btSt] = ui.proj.prepInitUIStruct(res.datOrg,res.opts);
        res.stg = [];
        res.stg.detect = 1;
        res.stg.post = 1;
    else
        [~,~,res.scl,res.btSt] = ui.proj.prepInitUIStruct(res.datOrg,res.opts,res.btSt);
    end
    
    % reset some settings
    if ~isfield(res,'dbg') || res.dbg==0
        res.btSt.overlayDatSel = 'Events';
    end
    
    opts = res.opts;
    scl = res.scl;
    stg = res.stg;
    ov = res.ov;
    fh.nEvt.String = num2str(numel(res.evt));
    
    res.btSt.sbs = 0;
    
    fns = fieldnames(res);
    for ii=1:numel(fns)
        f00 = fns{ii};
        setappdata(f,f00,res.(f00));
    end
end

waitbar(1,ff);

% UI
ui.proj.prepInitUI(f,fh,opts,scl,ov,stg,op);

fprintf('Done ...\n');
delete(ff);

end











