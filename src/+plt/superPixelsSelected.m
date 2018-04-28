function superPixelsSelected(spMap,spEvt)
voxLst = label2idx(spMap);
evt = zeros(size(spMap));
evt0 = unique(spEvt);
evt0 = evt0(evt0>0);
nEvt0 = numel(evt0);
for ii=1:nEvt0
    vox0 = voxLst(spEvt==evt0(ii));
    for jj=1:numel(vox0)
        vox00 = vox0{jj};
        evt(vox00) = evt0(ii);
    end
end
ov1 = plt.regionMapWithData(evt,evt*0,0.5); zzshow(ov1);
end