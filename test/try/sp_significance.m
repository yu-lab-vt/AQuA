varEst = opts.varEst;

zVec1 = stat.getSpZ(dat,lblMapS,varEst);
figure;hist(zVec1,100);

ov1 = plt.regionMapWithData(lblMapS,dat.^2,0.5); zzshow(ov1);

spLst = label2idx(lblMapS);
lblMapS1 = zeros(size(lblMapS));
for nn=1:numel(spLst)
    if zVec1(nn)>5
        lblMapS1(spLst{nn}) = nn;
    end
end

ov1 = plt.regionMapWithData(lblMapS1,dat.^2,0.5); zzshow(ov1);
