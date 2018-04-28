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

% status
btSt = [];
btSt.zoom = 0;
btSt.pan = 0;
btSt.play = 0;
btSt.overlayDatSel = 'None';
btSt.overlayFeatureSel = 'Index';
btSt.overlayColorSel = 'Random';
btSt.ftsFilter = [];  % features used for filtering
btSt.ftsCmd = [];  % features used for filtering
btSt.filterMsk = [];  % selected events by filter
btSt.regMask = [];  % selected events by region
btSt.evtMngrMsk = [];  % selected events by event manager

end



