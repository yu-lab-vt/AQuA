function loadExp(~,~,f)
cfgFile = 'uicfg.mat';
p0 = '.';
if exist(cfgFile,'file')
    xx = load(cfgFile);
    if isfield(xx,'cfg0') && isfield(xx.cfg0,'outPath')
        p0 = xx.cfg0.outPath;
    end
end
[FileName,PathName] = uigetfile({'*.mat'},'Choose saved results',p0);
if ~isnumeric(FileName)
    setappdata(f,'fexp',[PathName,filesep,FileName]);
    ui.proj.prep([],[],f,1);
end
end