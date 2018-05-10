% write a csv file using /cfg/batch.csv as template
% you can specify differet preset for each data
%
% results will be saved in 'outputFolder'
% use aqua_gui to read the results and do remaining tasks, like drawing cells and soma

startup;  % initialize

% specify output folder
outputFolder = 'D:\';

% specify input files
tb = readtable('./cfg/batch.csv','Delimiter',',');

% run detection
for nn=1:numel(tb.pathName)
    p0 = tb.pathName{nn};
    f0 = tb.fileName{nn};
    preset = tb.preset(nn);
    opts = util.parseParam(preset,0,'./cfg/parameters1.xlsx');
    opts.frameRate = tb.frameRate(nn);
    opts.spatialRes = tb.spatialRes(nn);
    
    % [dat,dF,opts,H,W,T] = burst.prep1(p0,f0,[],opts);
    % [dat,datSmo,dL,arLst,lmLoc,lmLocR] = burst.actTop(dat,dF,opts);
    % [lblMapS,~,~,riseMap] = burst.spTop(dat,dF,dL,datSmo,lmLoc,lmLocR,opts);
    % [fts,evt,dffMat,dRecon,~,~,lblMapE] = burst.evtTop(...
    %     dat,datSmo,dF,dL,lblMapS,riseMap,opts);
    % res = burst.gatherRes(dat,opts,evt,fts,dffMat,lblMapE,dRecon);
    % save([outputFolder,opts.fileName,'_res.mat'],'res');
end



