function [evtL,evtRecon,datWarpInt] = evtRecon(spLst,cx,evtMap0)

[H,W] = size(evtMap0);
[nSp,T] = size(cx);

evtRecon = zeros(H*W,T);
evtL = zeros(H*W,T);
datWarp = zeros(H,W,T);
seedMap1 = zeros(H,W);
for ii=1:nSp
    sp0 = spLst{ii};
    x0 = cx(ii,:);
    evtRecon(sp0,:) = repmat(x0,numel(sp0),1);
    l0 = mode(evtMap0(sp0));
    t0 = find(x0>0.1,1);
    t1 = find(x0>0.1,1,'last');
    evtL(sp0,t0:t1) = l0;
    [ih,iw] = ind2sub([H,W],sp0);
    datWarp(round(mean(ih)),round(mean(iw)),:) = x0;
    seedMap1(round(mean(ih)),round(mean(iw))) = ii;
end
evtRecon = reshape(evtRecon,H,W,T);
evtL = reshape(evtL,H,W,T);

% smoothing
for tt=1:T
    tmp = evtRecon(:,:,tt);
    tmp1 = imgaussfilt(tmp,0.5);
    tmp1(tmp==0) = 0;
    evtRecon(:,:,tt) = tmp1;    
end

% interpolation (optional)
datWarpInt = zeros(H,W,T);
if 0
    [y0,x0] = find(seedMap1>0);
    yx = sub2ind([H,W],y0,x0);
    [xq,yq] = meshgrid(1:W,1:H);
    for tt=1:T
        d0 = datWarp(:,:,tt);
        d0(isnan(d0)) = 0;
        v0 = d0(yx);
        vq = griddata(x0,y0,v0,xq,yq);
        vq(evtMap0==0) = 0;
        datWarpInt(:,:,tt) = vq;
    end
end

end
