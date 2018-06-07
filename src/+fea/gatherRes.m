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
res.fts = fts;
res.riseLst = riseLst;
res.dffMat = dffMat;
res.dMat = dMat;
% res.dRecon = dRecon;
% res.seLst = seLst;
% res.arLst = arLst;

ov = containers.Map('UniformValues',0);
ov('None') = [];

fprintf('Overlay for events...\n')
ov0 = ui.over.getOv([],evt,size(dRecon),dRecon);
ov0.name = 'Events';
ov0.colorCodeType = {'Random'};
ov(ov0.name) = ov0;

res.ov = ov;

fprintf('Done\n')

end


