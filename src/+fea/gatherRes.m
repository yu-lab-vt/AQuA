function res = gatherRes(dat,opts,evt,fts,dffMat,dMat,riseLst,dRecon)

opts.bitNum = 8;
dat1 = dat*(2^opts.bitNum-1);
if opts.bitNum<=8
    dat1 = uint8(dat1);
else
    dat1 = uint16(dat1);
end

res = [];
res.opts = opts;
res.dat = dat1;
res.evt = evt;
% res.seLst = seLst;
res.fts = fts;
res.riseLst = riseLst;
% res.evtRiseLink = evtRiseLink;
res.dffMat = dffMat;
res.dMat = dMat;

ov = containers.Map('UniformValues',0);
ov('None') = [];

% if ~isempty(dL)
%     fprintf('Overlay for active voxels...\n')
%     ov0 = ui.getOv(dL);
%     ov0.name = 'Active voxels';
%     ov0.colorCodeType = {'Random'};
%     ov(ov0.name) = ov0;
% end
% 
% if ~isempty(lblMapS)
%     fprintf('Overlay for super pixels...\n')
%     ov0 = ui.getOv(lblMapS);
%     ov0.name = 'Super pixels';
%     ov0.colorCodeType = {'Random'};
%     ov(ov0.name) = ov0;
% end

fprintf('Overlay for events...\n')
ov0 = ui.over.getOv(evt,size(dRecon),dRecon);
ov0.name = 'Events';
ov0.colorCodeType = {'Random'};
ov(ov0.name) = ov0;

% fprintf('Overlay for events...\n')
% ov0 = ui.getOv(seLst,size(dRecon),dRecon);
% ov0.name = 'Super events';
% ov0.colorCodeType = {'Random'};
% ov(ov0.name) = ov0;

res.ov = ov;

fprintf('Done\n')

end


