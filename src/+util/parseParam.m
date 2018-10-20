function [opts,optsInfo,optsName,cfg] = parseParam(cfgNum,~,cfgFile)
%GETPARAM read parameter configuration file

if ~exist('cfgNum','var')
    cfgNum = 1;
end

if ~exist('cfgFile','var')
    cfgFile = 'parameters1.csv';
end

opts = [];
optsInfo = [];
optsName = [];

cfg = readtable(cfgFile,'ReadVariableNames',false);
cfg = cfg(2:end,:);

% remove empty lines
cfg = cfg(~cellfun(@isempty,cfg.Var1),:);

vName = cfg{:,2};

val0 = cfg{:,4+cfgNum-1};

for ii=1:numel(vName)
    tmp = val0(ii);
    if iscell(tmp)
        tmp = tmp{1};
    end
    if ischar(tmp)
        tmp = str2double(tmp);
    end
    opts.(vName{ii}) = tmp;
end

tmp = load('normTopMeanDist'); 
opts.osTb = tmp.tbTopNorm;

end






