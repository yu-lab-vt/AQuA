function updtFeature(~,~,f,stg)
% updtFeature update network features after user draw regions
% regions are all in x,y coordinate, where y need to be flipped for matrix manipulation

fprintf('Updating basic, network, region and landmark features\n')

% read data
ov = getappdata(f,'ov');
opts = getappdata(f,'opts');
gg = waitbar(0,'Updating features ...');
sz = opts.sz;

% gather data
fprintf('Gathering data ...\n')
ov0 = ov('Events');
datL = zeros(sz,'uint32');
datR = zeros(sz,'uint8');
for tt=1:sz(3)
    tmpAll = zeros(sz(1),sz(2));
    ov00 = ov0.frame{tt};
    dRecon00 = zeros(sz(1),sz(2));
    if isempty(ov00)
        continue
    end
    for ii=1:numel(ov00.idx)
        idx00 = ov00.idx(ii);
        pix00 = ov00.pix{ii};
        val00 = ov00.val{ii};
        tmpAll(pix00) = idx00;
        dRecon00(pix00) = uint8(val00*255);
    end
    datR(:,:,tt) = dRecon00;
    datL(:,:,tt) = uint32(tmpAll);
end

% basic features
waitbar(0.2,gg);
dat = getappdata(f,'dat');
if stg==0
    fprintf('Updating basic features ...\n')
    [evtLst,ftsLst,dffMat,dMat] = fea.getFeaturesTop(dat,datL,opts);
    setappdata(f,'evt',evtLst);
    setappdata(f,'dffMat',dffMat);
    setappdata(f,'dMat',dMat);
else
    evtLst = getappdata(f,'evt');
    ftsLst = getappdata(f,'fts');
end

% propagation features
ftsLst = fea.getFeaturesPropTop(dat,datR,evtLst,ftsLst,opts);

% region, landmark and network
ui.detect.updtFeatureRegionLandmarkNetworkShow(f,datR,evtLst,ftsLst,gg);

% feature table
ui.detect.getFeatureTable(f);
fprintf('Done.\n')
delete(gg)

end







