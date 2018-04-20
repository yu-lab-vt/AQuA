function lblMap2F = filterAndFillSp(lblMap)
% filterAndFillSp remove small super voxels and fill holes

[H,W,T] = size(lblMap);

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
% resCellG = resCell(idxSel>0);

% clean
% lmIdxG = find(idxSel>0);
% nDisCon = 0;
% pixLstCutG1 = pixLstCutG;
% for ii=1:numel(pixLstCutG)
%     % choose the region
%     vox0 = pixLstCutG{ii};
%     [ih0,iw0,it0] = ind2sub([H,W,T],vox0);
%     rgH = min(ih0):max(ih0); ih1 = ih0 - min(ih0) + 1; H1 = numel(rgH);
%     rgW = min(iw0):max(iw0); iw1 = iw0 - min(iw0) + 1; W1 = numel(rgW);
%     rgT = min(it0):max(it0); it1 = it0 - min(it0) + 1; T1 = numel(rgT);
%     
%     vox1 = sub2ind([H1,W1,T1],ih1,iw1,it1);
%     pix1all = sub2ind([H1,W1],ih1,iw1);
%     pix1 = unique(pix1all);
%     pix1Map = zeros(H1,W1);
%     pix1Map(pix1) = 1;
%     
%     % choose parts connected to the seed
%     pixcc = bwconncomp(pix1Map,8);
%     ix = true(numel(vox0),1);
%     if pixcc.NumObjects>1
%         nDisCon = nDisCon + 1;
%         lm1 = lmAll(rgH,rgW,rgT);       
%         
%         % hash table has lower complexity ...
%         ixx = find(lm1>0);
%         [ixxh,ixxw,ixxt] = ind2sub([H1,W1,T1],ixx);
%         iyy = sub2ind([H,W,T],ixxh+min(rgH)-1,ixxw+min(rgW)-1,ixxt+min(rgT)-1);
%         idx2 = ixx(cell2mat(lmLocR.values(num2cell(iyy)))==lmIdxG(ii));  
% 
%         [ih2,iw2,~] = ind2sub([H1,W1,T1],idx2);
%         l1 = labelmatrix(pixcc);
%         if ~isempty(ih2)
%             cSel = l1(ih2(1),iw2(1));
%             if cSel>0
%                 ix = ismember(pix1all,pixcc.PixelIdxList{cSel});
%             end
%         end
%     end
%     
%     % clean small regions
%     vox1a = vox1(ix);
%     lbl2 = zeros(H1,W1,T1);
%     lbl2(vox1a) = 1:numel(vox1a);
%     
%     ix1 = lbl2(lbl2>0);
%     
%     vox0a = vox0(ix);
%     pixLstCutG1{ii} = vox0a(ix1);
% end

lblMap2 = zeros(H,W,T,'uint32');
for ii=1:numel(pixLstCutG)
    lblMap2(pixLstCutG{ii}) = uint32(ii);
end

% fill holes
lblMap2F = lblMap2;
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


