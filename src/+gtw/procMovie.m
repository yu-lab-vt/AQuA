function [dRecon,riseMap,riseLst] = procMovie(df,seLstAll,seSel,riseOnly,opts)
% procMovie apply GTW on each index labeled region
%
% df:       delta F movie
% seLstAll: all events, include evnets to avoid
% seLst:    indices of events to align
% riseOnly: discard the falling part of events.
%           set to 1 for visualization and feature extraction
%           set ot 0 for rising time refinement
% opts:     varEst
%
% TODO:
% improve temporal separation of super events after GTW

if isempty(seSel)
    seSel = 1:numel(seLstAll);
end

nSe = numel(seSel);
if nSe>1
    gaphw = 10;
else % if use only one (super) event, do not crop
    gaphw = 1e8;
end
varEst = opts.varEst;

[H,W,T] = size(df);
mapx = zeros(H,W,T);
for nn=1:numel(seLstAll)
    mapx(seLstAll{nn}) = nn;
end

% crop events
seLst = seLstAll(seSel);
rghLst = cell(nSe,1);
rgwLst = cell(nSe,1);
rgtLst = cell(nSe,1);
dfLst = cell(nSe,1);
mLst = cell(nSe,1);
vMapLst = cell(nSe,1);
for nn=1:nSe
    nnx = seSel(nn);
    se0 = seLstAll{nnx};
    if isempty(se0)
        continue
    end
    
    [ih0,iw0,it0] = ind2sub([H,W,T],se0);
    rgh = max(min(ih0)-gaphw,1):min(max(ih0)+gaphw,H);
    rgw = max(min(iw0)-gaphw,1):min(max(iw0)+gaphw,W);
    rgt = max((min(it0)-2),1):min((max(it0)+2),T);
    m0 = mapx(rgh,rgw,rgt);
    df0 = df(rgh,rgw,rgt);
    
    % GTW on movie with super pixels
    vMap0 = sum(m0==nnx,3)>0;
    vMap0Hole = imfill(vMap0,8,'holes')-vMap0;
    vMap0SmallHole = vMap0Hole - bwareaopen(vMap0Hole,4,4);
    vMap0(vMap0SmallHole>0) = 1;
    
    rghLst{nn} = rgh;
    rgwLst{nn} = rgw;
    rgtLst{nn} = rgt;
    dfLst{nn} = df0;
    mLst{nn} = m0;
    vMapLst{nn} = vMap0;
end

% alignment
varEstSp = varEst/8;
smoBase = 0.05;
maxStp = 11;

riseLst = cell(nSe,1);
riseMapLst = cell(nSe,1);
dwLst = cell(nSe,1);
rgt1Lst = cell(nSe,1);
% for nn=1:nSe
for nn=18
    fprintf('%d/%d\n',nn,nSe)
    nnx = seSel(nn);  % (super) event index
    se0 = seLst{nn};  % voxles in this event
    if isempty(se0)
        continue
    end
    df0 = dfLst{nn};
    m0 = mLst{nn};
    vMap0 = vMapLst{nn};

    try
        tic
        % get super pixels, curves and graph structure
        [df0ip,dfm,intMap,spSz,spLst] = gtw.dfMov2sp(df0,m0,vMap0,nnx,riseOnly,varEst);
        if isempty(spLst)  % too weak signal
            continue
        end
        [ref,tst,refBase,s,t,txx,spLst] = gtw.sp2graph(df0ip,vMap0,spLst,riseOnly,varEst);
        if isempty(ref)  % invalid shape of curve
            continue
        end
        
        % gtw alignment and extract information
        if numel(spLst)>3 && numel(refBase)>5
            maxStp1 = max(min(maxStp,ceil(numel(refBase)/2)),2);
            [ ss,ee,gInfo ] = gtw.buildGTWGraph( ref, tst, s, t, smoBase, maxStp1, varEstSp);
            [~, labels1] = aoIBFS.graphCutMex(ss,ee);
            path0 = gtw.label2path4Aosokin( labels1, ee, ss, gInfo );
        else
            [nPix,nTps] = size(tst);
            path0 = cell(nPix,1);
            rg = (0:nTps)';
            p0 = [rg,rg,rg+1,rg+1];
            for ii=1:nPix
                path0{ii} = p0;
            end
        end
        [datWarpInt,rMapAvg,datWarp,seedMap1] = gtw.anaGridPath(path0,spLst,dfm,vMap0,intMap,spSz,refBase);
        
        t00 = toc;
        if numel(se0)>100*100*50
            fprintf('Big event, %d voxels ',numel(se0))
            fprintf('Takes %fs\n',t00)
        end
        
        % gather results
        % rising map still cover the whole event, even falling part is not used in alignment
        msk0 = m0==nnx;
        rgt = rgtLst{nn};
        rgt1 = rgt(txx);
        rMap0 = repmat(rMapAvg+min(rgt1)-1,1,1,numel(rgt));
        rMap0 = rMap0.*msk0;
        
        % falling part is not reconstructed
        rgt1Lst{nn} = rgt1;
        msk0 = m0(:,:,txx)==nnx;
        dwLst{nn} = uint8(datWarpInt*255.*msk0);
        riseLst{nn} = rMapAvg;
        riseMapLst{nn} = rMap0;
    catch
        warning('Error in %d',nn)
    end
end

% merge reconstructed data
dRecon = zeros(H,W,T,'uint8');
riseMap = zeros(H,W,T);
for nn=1:nSe
    nnx = seSel(nn);
    se0 = seLstAll{nnx};
    if isempty(se0)
        continue
    end
    rgh = rghLst{nn};
    rgw = rgwLst{nn};
    rgt = rgtLst{nn};
    rgt1 = rgt1Lst{nn};
    dw0 = dwLst{nn};
    if ~isempty(dw0)
        dRecon(rgh,rgw,rgt1) = dRecon(rgh,rgw,rgt1) + dw0;
        rMap0 = riseMapLst{nn};
        riseMap(rgh,rgw,rgt) = max(riseMap(rgh,rgw,rgt),rMap0);
    end
end
riseMap(riseMap==0) = nan;

end




