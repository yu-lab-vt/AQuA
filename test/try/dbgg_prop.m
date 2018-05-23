% propagation check
ixVec = [9,52];

for ix=ixVec
    evt00 = res.fts.loc.x3D{ix};
    tmp = zeros(res.opts.sz,'uint8');
    tmp(evt00) = 1;
    [~,~,it00] = ind2sub(res.opts.sz,evt00);
    t0 = min(it00);
    t1 = max(it00);
    
    fprintf('%d\n',t0);
    
    r00 = tmp(:,:,t0:t1).*res.datRAll(:,:,t0:t1);
    
    zzshow(r00)
end

xx = res.fts.propagation.areaFrame{33};

%%
nEvt = size(dffMatE,1);
figure;
for ii=1:nEvt
    x = dffMatE(ii,:,1);
    y = dffMatE(ii,:,2);
    plot(x(:));hold on;plot(y(:));hold off
    keyboard
end