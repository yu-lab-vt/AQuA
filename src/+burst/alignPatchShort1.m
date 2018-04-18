function [lblMapS,dRecon,riseX,riseMap] = alignPatchShort1(dat,datSmo,lblMap,dL,opts)
% alignPatch Re-align pixels in each patch, divide large ones to super
% pixels and estimate the delay

[H,W,T] = size(dat);
spSz = opts.spSz;
voxLst = label2idx(lblMap);
nRg = numel(voxLst);

K = max(round(T/10),3);
datSmoMA = movmean(datSmo,K,3);
datSmoBase = min(datSmoMA,[],3);

dat = dat - datSmoBase;
datSmo = datSmo - datSmoBase;

% gather data for fitting
[datc,vmapc,vmapc1,tw1Vecc,rgHc,rgWc,rgTc,rgTxc] = ...
    burst.alignPatchShort1PrepReg(dat,datSmo,lblMap,dL,voxLst,opts);

% fitting
resc = cell(nRg,1);
% opts.gtwSmo = 0.2;
% parfor nn=1:numel(voxLst)
for nn=1:numel(voxLst)
    if mod(nn,100)==0; fprintf('%d\n',nn); end
    dat1 = datc{nn};
    if ~isempty(dat1)
        resc{nn} = burst.fitOnCr1(datc{nn},opts,vmapc{nn});
    end
end

% get super pixels and delay
[lblMapS,dRecon,riseX] = burst.alignPatchShort1SpDelay(...
    voxLst,resc,vmapc1,rgHc,rgWc,rgTc,rgTxc,tw1Vecc,spSz,H,W,T);

% rising time for each voxel
riseMap = zeros([H,W,T],'uint16');
spVoxLst = label2idx(lblMapS);
for nn=1:numel(spVoxLst)
    vox0 = spVoxLst{nn};
    if ~isempty(vox0)
        riseMap(vox0) = uint16(riseX(nn));
    end
end

end





