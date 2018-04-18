function [pixBorder,pixHole] = getRegBorder( regMap )
%GETREGBORDER Get border edge pixels for each region
% upsample the map and trace the boundaries
% for coordinates in Fiji, use (BB-1)/2

[H,W] = size(regMap);
nReg = max(regMap(:));
pixBorder = cell(1,nReg);
pixHole = cell(1,nReg);

ofsth = [-1  0  1 -1 0 1 -1 0 1];
ofstw = [-1 -1 -1  0 0 0  1 1 1];

for ii=1:nReg
    fprintf('%d\n',ii)
    map0 = regMap==ii;
    
    % Outer
    [ih,iw] = find(map0>0);
    map1 = zeros(2*H+1,2*W+1);
    ih2 = 2*ih;
    iw2 = 2*iw;
    ihIdx = repmat(ih2,1,9) + repmat(ofsth,length(ih2),1);
    iwIdx = repmat(iw2,1,9) + repmat(ofstw,length(iw2),1);
    idx = sub2ind([2*H+1,2*W+1],ihIdx,iwIdx);
    map1(idx) = 1;
    L = bwlabel(map1, 8);
    pixBorder{ii} = bwboundariesmex(L, 4);    
    
    % Inner
    map0Fill = imfill(map0,'holes');
    map0h = (1 - map0).*map0Fill;
    [ih,iw] = find(map0h>0);
    map1 = zeros(2*H+1,2*W+1);
    ih2 = 2*ih;
    iw2 = 2*iw;
    ihIdx = repmat(ih2,1,9) + repmat(ofsth,length(ih2),1);
    iwIdx = repmat(iw2,1,9) + repmat(ofstw,length(iw2),1);
    idx = sub2ind([2*H+1,2*W+1],ihIdx,iwIdx);
    map1(idx) = 1;    
    L = bwlabel(map1, 8);
    tmp1 = bwboundariesmex(L, 4);
    
    % Inner-inner
    map0hFill = imfill(map0h,'holes');
    map0hh = (1 - map0h).*map0hFill;
    [ih,iw] = find(map0hh>0);
    map1 = zeros(2*H+1,2*W+1);
    ih2 = 2*ih;
    iw2 = 2*iw;
    ihIdx = repmat(ih2,1,9) + repmat(ofsth,length(ih2),1);
    iwIdx = repmat(iw2,1,9) + repmat(ofstw,length(iw2),1);
    idx = sub2ind([2*H+1,2*W+1],ihIdx,iwIdx);
    map1(idx) = 1;    
    L = bwlabel(map1, 8);
    tmp2 = bwboundariesmex(L, 4);
    pixHole{ii} = [tmp1;tmp2];
end

end

