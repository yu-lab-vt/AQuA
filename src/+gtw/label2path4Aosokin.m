function resPath = label2path4Aosokin( labels, ee, ss, gInfo )
%label2path4Aosokin Convert label of src and sink to path in primal graph
% For the graph representation of Aosokin's codes
% Src and sink edges do not use explicit node names, but other edges do

% cs = find(labels==0);
ct = find(labels==1);

nEdgeGrid = gInfo.nEdgeGrid;
nNodeGrid = gInfo.nNodeGrid;
nPix = gInfo.nPix;

pEdgeSS = gInfo.pEdgeSS;
pEdgeEE = gInfo.pEdgeEE;
dEdgeIntSS = gInfo.dEdgeIntSS;

% cut for within grid
% not suitable do this pixel by pixel due to the spatial edge
dtmp = zeros(size(ee,1),2);
ia = ismember(ee(:,1:2),ct);
dtmp(ia) = 1;
isCutEE = dtmp(:,1)~=dtmp(:,2);

% cut to mapping pattern in primal graph
resPath = cell(nPix,1);
for nn=1:nPix
    % cuts within grid
    idx1 = nEdgeGrid*(nn-1) + 1;
    idx2 = nEdgeGrid*nn;
    cutNow = isCutEE(idx1:idx2);
    resEE = pEdgeEE(cutNow,:);
    
    % src and sink cuts
    idx1 = nNodeGrid*(nn-1) + 1;
    idx2 = nNodeGrid*nn;
    s0 = ss(idx1:idx2,:);
    b0 = labels(idx1:idx2);
    
    % FIXME: we already use dEdgeIntSS(:,2) to filter out nodes not connected to s/t
    % so s0(:,1)>=0 or s0(:,2)>=0 is not needed
    
    idxSrcCut = find(s0(:,1)>=0 & b0==1);  % nodes that cuts
    ia = ismember(dEdgeIntSS(:,2),idxSrcCut);  % get corresponding edges, src -> node
    resSrc = pEdgeSS(ia,:);  % the primal edges
    
    idxSinkCut = find(s0(:,2)>=0 & b0==0);
    ia = ismember(dEdgeIntSS(:,1),idxSinkCut);  % node -> sink
    resSink = pEdgeSS(ia,:);
    
    resPath{nn} = [resEE;resSrc;resSink];
end

end



