function [opts,optsInfo,optsName,cfg,pName] = parseParam(cfgNum,cfgNumSel,cfgFile)
%GETPARAM read parameter configuration file

if ~exist('cfgNum','var')
    cfgNum = 1;
end

if ~exist('cfgSel','var')
    cfgNumSel = 0;
end

if ~exist('cfgFile','var')
    cfgFile = './cfg/parameters1.csv';
end

opts = [];
optsInfo = [];
optsName = [];

cfg = readtable(cfgFile);

% remove empty lines
cfg = cfg(~cellfun(@isempty,cfg.Variable),:);

% fill empty terms
pName = cell(0);
f00 = fieldnames(cfg);
if size(cfg,2)>5
    tmp0 = cfg{:,4};  % default
    pName{1} = f00{4};
    for ii=5:size(cfg,2)-1
        tmp = cfg{:,ii};
        tmp(isnan(tmp)) = tmp0(isnan(tmp));
        cfg{:,ii} = tmp;
        pName{ii-3} = f00{4+ii-4};
    end
end

% user select profile
vName = cfg{:,2};
if cfgNumSel>0
    cfgNum = listdlg('PromptString','Which best describe your data?',...
        'SelectionMode','single','ListString',pName);
    if isempty(cfgNum)
        return
    end
end
val0 = cfg{:,4+cfgNum-1};
% vInfo0 = cfg{:,end};
% vName0 = cfg{:,1};

for ii=1:numel(vName)
    opts.(vName{ii}) = val0(ii);
    %optsInfo.(vName{ii}) = vInfo0{ii};
    %optsName.(vName{ii}) = vName0{ii};
end

end






