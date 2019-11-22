function lblMap2F = filterAndFillSp(lblMap)
% filterAndFillSp remove small super voxels and fill holes

[H,W,T] = size(lblMap);
% lblMap2F = zeros(H,W,T,'uint32');

% remove seeds with small regions patch
pixLstCut = label2idx(lblMap);
nLm = numel(pixLstCut);
idxSel = zeros(nLm,1);
for ii=1:min(nLm,numel(pixLstCut))
    pix00 = pixLstCut{ii};
    %res00 = resCell{ii};
    if ~isempty(pix00)
        [ih,iw,~] = ind2sub([H,W,T],pix00);
        fiux0g = unique(sub2ind([H,W],ih,iw));
        if numel(fiux0g)>4 || numel(ih)>8
        %if numel(fiux0g)>4 || numel(ih)>8 || res00.szAll>0
            idxSel(ii) = 1;
        end
    end
end
pixLstCutG = pixLstCut(idxSel>0);
nLmG = sum(idxSel);
if nLmG==0
    return
end

lblMap2F = zeros(H,W,T,'uint32');
for ii=1:numel(pixLstCutG)
    lblMap2F(pixLstCutG{ii}) = uint32(ii);
end

% fill holes
dh = [-1 1 0 0];
dw = [0 0 -1 1];
for tt=1:T
    L = lblMap2F(:,:,tt);
    Lb = L>0;
    Lf = imfill(Lb>0,'holes');
    Lh = Lf - Lb;
    Lhcc = bwconncomp(Lh);
    for ii=1:Lhcc.NumObjects
        pix0 = Lhcc.PixelIdxList{ii};
        [ih,iw] = ind2sub([H,W],pix0);
        neibLst = [];
        isGood = 1;
        for jj=1:numel(dh)
            ih1 = ih+dh(jj); ih1 = max(min(ih1,H),1);
            iw1 = iw+dw(jj); iw1 = max(min(iw1,W),1);
            pix1 = sub2ind([H,W],ih1,iw1);
            x = L(pix1);
            x = x(x>0);
            x = unique(x);
            neibLst = union(neibLst,x);
            if numel(neibLst)>1
                isGood = 0;
                break
            end
        end
        if isGood
            L(pix0) = neibLst(1);
        end
    end
    lblMap2F(:,:,tt) = uint32(L);
end

end


