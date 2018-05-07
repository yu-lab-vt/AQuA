function [ov,bd,scl,btSt] = prepInitUIStruct(dat,opts)

[H,W,T] = size(dat);

% initial overlays and boundaries
ov = containers.Map('UniformValues',0);
ov('None') = [];
bd = containers.Map('UniformValues',0);  % foregrnd, backgrnd, region, landmk
bd('None') = [];

% set layer scale
scl = [];
if opts.usePG==0
    scl.min = min(dat(:));
    scl.max = max(dat(:));
    scl.map = 0;
else
    scl.min = min(dat(:)).^2;
    scl.max = max(dat(:)).^2;
    scl.map = 1;
end
scl.bri = 1;
scl.briOv = 0.5;
scl.minOv = 0;
scl.maxOv = 1;
scl.hrg = [1,H];
scl.wrg = [1,W];
scl.H = H;
scl.W = W;
scl.T = T;

btSt = ui.proj.initStates();


end



