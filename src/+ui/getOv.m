function ov = getOv(arLst,sz,reCon)
% getOv color code each 3D region
% Returns an overlay object
% ov.frame.idx:  vector of region index
%         .pix:  cell of pixels
%         .val:  cell of reconstructed values
%   .idx      :  vector of all index
%   .col      :  N by 3 array of colors. For different color code, update this field
%   .sel      :  N by 1 logic vector indicating whether this event is selected or not

seedx = round(rand()*10000);
rng(seedx);
if ~exist('reCon','var') || isempty(reCon) 
    reCon = ones(sz)*255;
end

ov = [];
T = sz(3);
ov.frame = cell(T,1);

regionMap = zeros(sz,'uint32');
idxSel = zeros(1,numel(arLst));
for nn=1:numel(arLst)
    regionMap(arLst{nn}) = uint32(nn);
    if ~isempty(arLst{nn})
        idxSel(nn) = 1;
    end
end
idx = find(idxSel>0);

% color for each region
% idx = unique(regionMap(:)); idx = idx(idx>0);
% nEvt = numel(idx);
nEvt = max(idx);
ov.idx = 1:nEvt;
idxValid = zeros(nEvt,1); idxValid(idx) = 1;
ov.idxValid = idxValid;
ov.col = ui.getColorCode(nEvt);
ov.colVal = 1:nEvt;
ov.sel = ones(nEvt,1);

% pix for each region at each frame
for tt=1:T
    reg0 = regionMap(:,:,tt);
    rec0 = double(reCon(:,:,tt))/255;
    reg0a = reg0(reg0>0);
    nReg = numel(unique(reg0a));
    if nReg>0
        reg0aMin = min(reg0a);
        reg0(reg0>0) = reg0(reg0>0)-reg0aMin+1;
        cc = label2idx(reg0);
        f0 = [];
        f0.idx = zeros(nReg,1);
        f0.pix = cell(nReg,1);
        f0.val = cell(nReg,1);
        ee = 1;
        for nn=1:numel(cc)
            pix0 = cc{nn};
            if ~isempty(pix0)
                f0.idx(ee) = nn+reg0aMin-1;
                f0.pix{ee} = pix0;
                f0.val{ee} = rec0(pix0);
                ee = ee + 1;
            end            
        end 
        ov.frame{tt} = f0;
    end
end

end




