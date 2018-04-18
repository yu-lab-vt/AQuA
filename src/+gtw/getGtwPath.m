function [path0,bdsCell] = getGtwPath( ref, tst, validMap, param )
%GETGTWPATH Use GTW to get the warping path

if param.winSize>1
    [ ss,ee,gInfo ] = gtw.buildGraph4Aosokin( ref, tst, validMap, param);
    
    % IBFS at least 40% faster than B-K here
    [~, labels] = aoIBFS.graphCutMex(ss,ee);
    % tic; [~, labels] = aoBK.graphCutMex(ss,ee); toc
    %warning('haha');
    
    % warping functions
    path0 = gtw.label2path4Aosokin( labels, ee, ss, gInfo );
    
    % map of labels
    bdsCell = param.bdsCell;
    nNodeGrid = gInfo.nNodeGrid;
    nPix = gInfo.nPix;    
    [ix,iy] = find(validMap>0);
    for nn=1:nPix
        ix0 = ix(nn);
        iy0 = iy(nn);
        if param.bds(ix0,iy0)>0
            idx1 = nNodeGrid*(nn-1) + 1;
            idx2 = nNodeGrid*nn;
            b0 = labels(idx1:idx2);
            bdsCell{ix0,iy0} = b0;
        end
    end    
else  % no warping at all
    [nPix,nTps] = size(tst);
    path0 = cell(nPix,1);
    rg = (0:nTps)';
    p0 = [rg,rg,rg+1,rg+1];
    for ii=1:nPix
        path0{ii} = p0;
    end
    bdsCell = param.bdsCell;
end

end

