%% setup
% -- preset 1: original Lck. 2: Jen Lck. 5: GluSnFR
% 
%
% Read Me:
% 'p0' is the folder containing tifs you want to deal with.
% Suggest sort the files in order, so that you can set the parameters 
% conviniently. AQuA/cfg/parameters_for_batch is the parameters excel.
% The script will read the parameters from that excel to deal with data.
% How many files you have, how many parameter settings should be in that excel.

close all
clearvars
startup;  % initialize
load('random_Seed.mat');
rng(s);

p0 = 'D:\'; %% tif folder

%% For cell boundary and landmark
p_cell = '';   % cell boundary path, if you have
p_landmark = '';   % landmark path, if you have

bd = containers.Map;
bd('None') = [];
if(~strcmp(p_cell,''))
    cell_region = load(p_cell);
    bd('cell') = cell_region.bd0;
    
end
if(~strcmp(p_landmark,''))
    landmark = load(p_landmark);
    bd('landmk') = landmark.bd0;
end

files = dir(fullfile(p0,'*.tif'));  

%% 
for x = 1:size(files,1)

    f0 = files(x).name;  % file name

    %% Note: Setting the parameters should be consistent with your target file
    opts = util.parseParam_for_batch(x,0);
    [datOrg,opts] = burst.prep1(p0,f0,[],opts);  % read data
    [folder, name, ext] = fileparts(strcat(p0,'\',f0));

    %% detection
    sz = opts.sz;
    evtSpatialMask = ones(sz(1),sz(2));
    if bd.isKey('cell')
        bd0 = bd('cell');
        evtSpatialMask = zeros(sz(1),sz(2));
        for ii=1:numel(bd0)
            idx = bd0{ii}{2};
            spaMsk0 = zeros(sz(1),sz(2));
            spaMsk0(idx) = 1;
            evtSpatialMask(spaMsk0>0) = 1;
        end
    end
    [dat,dF,~,lmLoc,opts,dL] = burst.actTop(datOrg,opts,evtSpatialMask);  % foreground and seed detection
    [svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,evtSpatialMask,opts);  % super voxel detection

    [riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts,[],bd);  % events
    [ftsLst,dffMat] = fea.getFeatureQuick(datOrg,evtLst,opts);

    % filter by significance level
    mskx = ftsLst.curve.dffMaxZ>opts.zThr;
    dffMatFilterZ = dffMat(mskx,:);
    evtLstFilterZ = evtLst(mskx);
    tBeginFilterZ = ftsLst.curve.tBegin(mskx);
    riseLstFilterZ = riseLst(mskx);

    % merging (glutamate)
    evtLstMerge = burst.mergeEvt(evtLstFilterZ,dffMatFilterZ,tBeginFilterZ,opts,bd);

    % reconstruction (glutamate)
    if opts.extendSV==0 || opts.ignoreMerge==0 || opts.extendEvtRe>0
        [riseLstE,datRE,evtLstE] = burst.evtTopEx(dat,dF,evtLstMerge,opts);
    else
        riseLstE = riseLstFilterZ; datRE = datR; evtLstE = evtLstFilterZ;
    end

    % feature extraction
    [ftsLstE,dffMatE,dMatE] = fea.getFeaturesTop(datOrg,evtLstE,opts);
    ftsLstE = fea.getFeaturesPropTop(dat,datRE,evtLstE,ftsLstE,opts);

    % update network features
    sz = size(datOrg);
    evtx1 = evtLstE;
    ftsLstE.networkAll = [];
    ftsLstE.network = [];
    if bd.isKey('cell')
        bd0 = bd('cell');
        evtSpatialMask = zeros(sz(1),sz(2));
        regLst = cell(numel(bd0),1);
        for ii=1:numel(bd0)
            pix00 = bd0{ii}{2};
            regLst{ii} = pix00;
            evtSpatialMask(pix00) = 1;
        end
    else
    regLst = [];
    evtSpatialMask = ones(sz(1),sz(2));
    end

    if bd.isKey('landmk')
        bd1 = bd('landmk');
        lmkLst = cell(numel(bd1),1);
        for ii=1:numel(bd1)
            lmkLst{ii} = bd1{ii}{2};
        end
    else
        lmkLst = [];
    end

    try
        if ~isempty(regLst) || ~isempty(lmkLst)
            fprintf('Updating region and landmark features ...\n')
            ftsLstE.region = fea.getDistRegionBorderMIMO(evtLstE,datR,regLst,lmkLst,opts.spatialRes,opts.minShow1);
            if bd.isKey('cell')
                bd0 = bd('cell');
                for i = 1:numel(regLst)
                    cname{i} = bd0{i}{4};
                    if(strcmp(cname{i},'None'))
                        cname{i} = num2str(i);
                    end
                end
                ftsLstE.region.cell.name = cname;
            end
            if bd.isKey('landmk')
                bd0 = bd('landmk');
                for i = 1:numel(lmkLst)
                    lname{i} = bd0{i}{4};
                    if(strcmp(lname{i},'None'))
                        lname{i} = num2str(i);
                    end
                end
                ftsLstE.region.landMark.name = lname;
            end
        end
    catch
    end

    try
        ftsLstE.networkAll = fea.getEvtNetworkFeatures(evtLstE,sz);  % all filtered events
        ftsLstE.network = fea.getEvtNetworkFeatures(evtx1,sz);  % events inside cells only
    catch
    end


    %% export table
    fts = ftsLstE;
    tb = readtable('userFeatures.csv','Delimiter',',');
    if(isempty(ftsLstE.basic))
        nEvt = 0;
    else
        nEvt = numel(ftsLstE.basic.area);
    end
    nFt = numel(tb.Name);
    ftsTb = nan(nFt,nEvt);
    ftsName = cell(nFt,1);
    ftsCnt = 1;
    dixx = ftsLstE.notes.propDirectionOrder;
    lmkLst = [];

    for ii=1:nFt
    cmdSel0 = tb.Script{ii};
    ftsName0 = tb.Name{ii};
    % if find landmark or direction
    if ~isempty(strfind(cmdSel0,'xxLmk')) %#ok<STREMP>
        for xxLmk=1:numel(lmkLst)
            try
                eval([cmdSel0,';']);
            catch
                fprintf('Feature "%s" not used\n',ftsName0)
                x = nan(nEvt,1);
            end
            ftsTb(ftsCnt,:) = reshape(x,1,[]);
            ftsName1 = [ftsName0,' - landmark ',num2str(xxLmk)];
            ftsName{ftsCnt} = ftsName1;
            ftsCnt = ftsCnt + 1;
        end
    elseif ~isempty(strfind(cmdSel0,'xxDi')) %#ok<STREMP>
        for xxDi=1:4
            try
                eval([cmdSel0,';']);
                ftsTb(ftsCnt,:) = reshape(x,1,[]);
            catch
                fprintf('Feature "%s" not used\n',ftsName0)
                ftsTb(ftsCnt,:) = nan;
            end            
            ftsName1 = [ftsName0,' - ',dixx{xxDi}];
            ftsName{ftsCnt} = ftsName1;
            ftsCnt = ftsCnt + 1;
        end
    else
        try
            eval([cmdSel0,';']);
            ftsTb(ftsCnt,:) = reshape(x,1,[]);            
        catch
            fprintf('Feature "%s" not used\n',ftsName0)
            ftsTb(ftsCnt,:) = nan;
        end
        ftsName{ftsCnt} = ftsName0;
        ftsCnt = ftsCnt + 1;
    end
    end
    featureTable = table(ftsTb,'RowNames',ftsName);
    
    path0 = [p0,name,'\'];
    if ~exist(path0,'dir') && ~isempty(path0)
        mkdir(path0);    
    end

    ftb = [path0,name,'_FeatureTable.xlsx'];
    writetable(featureTable,ftb,'WriteVariableNames',0,'WriteRowNames',1);

    %% export movie
    datL = zeros(opts.sz);
    for i = 1:numel(evtLstE)
    datL(evtLstE{i}) = i; 
    end
    ov1 = zeros(opts.sz(1),opts.sz(2),3,opts.sz(3));
    % re-scale movie
    c0 = zeros(nEvt,3);
    for nn=1:nEvt
    x = rand(1,3);
    while (x(1)>0.8 && x(2)>0.8 && x(3)>0.8) || sum(x)<1
        x = rand(1,3);
    end
    x = x/max(x);
    c0(nn,:) = x;
    end

    for tt=1:opts.sz(3)
    if mod(tt,100)==0
        fprintf('Frame %d\n',tt); 
    end
    dat0 = datOrg(:,:,tt);
    if opts.usePG==1
        dat0 = dat0.^2;
    end
    datx = cat(3,dat0,dat0,dat0);
    datxCol = datx;
    [H,W,~] = size(datx);
    reCon = double(datRE(:,:,tt))/255;
    rPlane = zeros(H,W);
    gPlane = rPlane;
    bPlane = rPlane;
    map = datL(:,:,tt);
    rPlane(map>0) = c0(map(map>0),1);
    gPlane(map>0) = c0(map(map>0),2);
    bPlane(map>0) = c0(map(map>0),3);
    datxCol(:,:,1) = rPlane.*reCon + datxCol(:,:,1);
    datxCol(:,:,2) = gPlane.*reCon + datxCol(:,:,2);
    datxCol(:,:,3) = bPlane.*reCon + datxCol(:,:,3);
    ov1(:,:,:,tt) = datxCol;
    end
    fmov = [path0,name,'_Movie.tif'];
    io.writeTiffSeq(fmov,ov1,8);


    %% export to GUI
    res = fea.gatherRes(datOrg,opts,evtLstE,ftsLstE,dffMatE,dMatE,riseLstE,datRE);
    % aqua_gui(res);

    % visualize the results in each step
    if 0
        ov1 = plt.regionMapWithData(arLst,datOrg,0.5); zzshow(ov1);
        ov1 = plt.regionMapWithData(svLst,datOrg,0.5); zzshow(ov1);
        ov1 = plt.regionMapWithData(seLst,datOrg,0.5,datR); zzshow(ov1);
        ov1 = plt.regionMapWithData(evtLst,datOrg,0.5,datR); zzshow(ov1);
        ov1 = plt.regionMapWithData(evtLstFilterZ,datOrg,0.5,datR); zzshow(ov1);
        ov1 = plt.regionMapWithData(evtLstMerge,datOrg,0.5,datR); zzshow(ov1);
        [ov1,lblMapS] = plt.regionMapWithData(evtLstE,datOrg,0.5,datRE); zzshow(ov1);
    end

    %% save output
    res.bd = bd;
    save([path0,name,'_AQuA.mat'], 'res');
end
    



