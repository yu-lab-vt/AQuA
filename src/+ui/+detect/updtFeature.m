function updtFeature(~, ~, f, stg)
    % updtFeature update network features after user draw regions
    % regions are all in x,y coordinate, where y need to be flipped for matrix manipulation

    fprintf('Updating basic, network, region and landmark features\n')

    % read data
    ov = getappdata(f, 'ov');
    opts = getappdata(f, 'opts');
    evtLst = getappdata(f, 'evt');
    
    fh = guidata(f);
    fh.nEvtName.String = 'nEvt';
    fh.nEvt.String = num2str(numel(evtLst));
    
    gg = waitbar(0, 'Updating features ...');
    sz = opts.sz;

    % gather data
    fprintf('Gathering data ...\n')
    ov0 = ov('Events');
    datR = zeros(sz, 'uint8');

    for tt = 1:sz(3)
        ov00 = ov0.frame{tt};
        dRecon00 = zeros(sz(1), sz(2));

        if isempty(ov00)
            continue
        end 

        for ii = 1:numel(ov00.idx)
            pix00 = ov00.pix{ii};
            val00 = ov00.val{ii};
            dRecon00(pix00) = uint8(val00 * 255);
        end 

        datR(:, :, tt) = dRecon00;
    end 

    % basic features
    waitbar(0.2, gg);
    dat = getappdata(f, 'dat');
    datOrg = getappdata(f, 'datOrg');

    if stg == 0
        fprintf('Updating basic features ...\n')
        [ftsLstE, dffMat, dMat] = fea.getFeaturesTop(datOrg, evtLst, opts);
        setappdata(f, 'dffMat', dffMat);
        setappdata(f, 'dMat', dMat);
    else 
        ftsLstE = getappdata(f, 'fts');
    end 

    % propagation features
    ftsLstE = fea.getFeaturesPropTop(dat, datR, evtLst, ftsLstE, opts);

    % region, landmark, network and save results
    ui.detect.updtFeatureRegionLandmarkNetworkShow(f, datR, evtLst, ftsLstE, gg);

    % feature table
    ui.detect.getFeatureTable(f);
    fprintf('Done.\n')
    delete(gg)

end 



