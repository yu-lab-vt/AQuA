function [lblMapC,evtLst,bins] = sp2EvtTree(lblMapS,riseX,propUR,propCT,exclRat)
% sp2EvtTree detect events from superpixels (SPs)

% propUR = 1;  % propagation direction uncertainty range 
% propCT = 5;  % propagation continuity threshold

riseX = reshape(riseX,[],1);

[H,W,T] = size(lblMapS);
lblMapSVec = reshape(lblMapS,[],T);
spVoxLst = label2idx(lblMapS);
nSP = numel(spVoxLst);
spPixLst = cell(nSP,1);
for nn=1:nSP
    vox = spVoxLst{nn};
    [ih,iw,~] = ind2sub([H,W,T],vox);
    spPixLst{nn} = unique(sub2ind([H,W],ih,iw));
end

% distance matrix and exclusion map
dh = [-1 0 1 -1 1 -1 0 1];
dw = [-1 -1 -1 0 0 1 1 1];
exldLst = cell(nSP,1);  % for each SP, the SP overlapped with it if z-projected
distMat = nan(nSP,nSP);
for nn=1:nSP
    if nn==189
%         keyboard
    end
    vox = spVoxLst{nn};
    [ih,iw,it] = ind2sub([H,W,T],vox);
    for ii=1:numel(dh)
        ih1 = min(max(ih + dh(ii),1),H);
        iw1 = min(max(iw + dw(ii),1),W);
        voxShift = sub2ind([H,W,T],ih1,iw1,it);
        x = lblMapS(voxShift);
        x = x(x>0);
        x = unique(x);
        x = x(x~=nn);
        if ~isempty(x)
            d = riseX(nn) - riseX(x);  % positive is earlier
            if abs(d)<=propCT
                distMat(nn,x) = d;
                distMat(x,nn) = -d;
            end
        end
    end
    distMat(nn,nn) = 0;
    
    % conflicting SPs
    ihw = unique(sub2ind([H,W],ih,iw));
    x = lblMapSVec(ihw,:);
    x = x(x>0);    
    u = unique(x);
    u = u(u~=nn);
    e0 = [];
    for ii=1:numel(u)
        u1 = u(ii);
        ihw1 = spPixLst{u1};        
        if numel(intersect(ihw,ihw1))/numel(ihw)>exclRat        
            e0 = union(e0,u1);
        end
    end
    exldLst{nn} = e0;
end

%% grow tree by searching from earlier events to later ones
% TODO may need distance penalty term
% TODO post refining may be needed
bins = nan(nSP,1);  % event label for each SP
[~,spRiseOrder] = sort(riseX,'ascend');
nEvt = 0;
% % for nn=1:500
for nn=1:nSP
    spCur = spRiseOrder(nn);
    rise0 = riseX(spCur);
    if mod(nn,100)==0
        fprintf('SP %d / %d\n',nn,nSP)
    end
    if spCur==189
%         keyboard
    end
    sp0 = find(bins>0 & riseX>=rise0-propCT);  % do not look for too early SPs
    
    % avoid conflicts, clean sp0
    x = bins(exldLst{spCur});
    x = x(x>0);
    x = unique(x);
    if ~isempty(x)
        for ii=1:numel(sp0)
            if sum(bins(sp0(ii))==x)>0
                sp0(ii) = nan;
            end
        end
    end   
    sp0 = reshape(sp0(~isnan(sp0)),[],1);
    
    % If no existing event, this is a new source
    if isempty(sp0)
        nEvt = nEvt + 1;
        bins(spCur) = nEvt;
        continue
    end
    
    % SPs within propagation uncertainty
    sp1 = find(riseX>=rise0 & riseX<rise0+propUR);
    if ~isempty(x)
        for ii=1:numel(sp1)
            if sum(bins(sp1(ii))==x)>0
                sp1(ii) = nan;
            end
        end
    end       
    sp1 = sp1(~isnan(sp1));
    sp1 = reshape(setdiff(sp1,sp0),[],1);
    
    sp = [sp0;sp1];
    s0 = find(sp==spCur);
    t0 = 1:numel(sp0);
    
    dist0 = distMat(sp,sp);
    [s,t] = find(~isnan(dist0));

    w = abs(dist0(~isnan(dist0)));
    G = digraph(s,t,w);
    d = distances(G,s0,t0);
    [d0,ix] = min(d);  
    
    if ~isinf(d0)
        bins(spCur) = bins(sp0(ix));
    else
        nEvt = nEvt + 1;
        bins(spCur) = nEvt;
    end
end

%% output
evtLst = label2idx(bins);
lblMapC = zeros(H,W,T);
for nn=1:numel(bins)
    vox0 = spVoxLst{nn};
    lblMapC(vox0) = bins(nn);    
end


end





