%% setup
% -- preset 1: in vivo. 2: ex vivo. 3: GluSnFR
startup;  % initialize

preset = 1;
p0 = 'D:\';  % folder name
f0 = 'Test.tif';  % file name

%% save path
[folder, name, ext] = fileparts(strcat(p0,'\',f0));
path0 = [p0,name,'\'];
if ~exist(path0,'dir') && ~isempty(path0)
    mkdir(path0);    
end

ftb = [path0,name,'_FeatureTable.xlsx'];       % Movie Path
fmov = [path0,name,'_Movie.tif'];


opts = util.parseParam(preset,1);

% opts.smoXY = 1;
% opts.thrARScl = 2;
% opts.movAvgWin = 15;
% opts.minSize = 8;
% opts.regMaskGap = 0;
% opts.thrTWScl = 5;
% opts.thrExtZ = 0.5;
% opts.extendSV = 1;
% opts.cRise = 1;
% opts.cDelay = 2;
% opts.zThr = 3;
% opts.getTimeWindowExt = 10000;
% opts.seedNeib = 5;
% opts.seedRemoveNeib = 5;
% opts.thrSvSig = 1;
% opts.extendEvtRe = 0;

[datOrg,opts] = burst.prep1(p0,f0,[],opts);  % read data

%% detection
[dat,dF,arLst,lmLoc,opts,dL] = burst.actTop(datOrg,opts);  % foreground and seed detection
[svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);  % super voxel detection

[riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts);  % events
[ftsLst,dffMat] = fea.getFeatureQuick(datOrg,evtLst,opts);

% fitler by significance level
mskx = ftsLst.curve.dffMaxZ>opts.zThr;
dffMatFilterZ = dffMat(mskx,:);
evtLstFilterZ = evtLst(mskx);
tBeginFilterZ = ftsLst.curve.tBegin(mskx);
riseLstFilterZ = riseLst(mskx);

% merging (glutamate)
evtLstMerge = burst.mergeEvt(evtLstFilterZ,dffMatFilterZ,tBeginFilterZ,opts,[]);

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
try
    ftsLstE.networkAll = fea.getEvtNetworkFeatures(evtLstE,sz);  % all filtered events
    ftsLstE.network = fea.getEvtNetworkFeatures(evtx1,sz);  % events inside cells only
catch
end

%% export table
fts = ftsLstE;
tb = readtable('userFeatures.csv','Delimiter',',');
nEvt = numel(ftsLstE.basic.area);
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

save([path0,name,'_AQuA.mat'], 'res');

