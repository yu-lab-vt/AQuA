function [spMap,spRec,spRise] = detectTopPara1(dIn,dL,dMskSeed,opts)

[H,W,T] = size(dIn);

opts.thrx = opts.thrTWScl*sqrt(opts.varEst);

arLst = label2idx(dL);
nAR = numel(arLst);

dInSTc = cell(1,nAR);
mskSTc = cell(1,nAR);
pixc = cell(1,nAR);
rgTc = cell(1,nAR);
rgHc = cell(1,nAR);
rgWc = cell(1,nAR);

% [~,arLenOrder] = sort(cellfun(@numel,arLst),'descend');

% extract candidate regions for parallel detection
gaph = 3;  % !!
gapt = 3;
for ii=1:nAR
    %kk = arLenOrder(ii);
    kk = ii;
    pix0 = arLst{kk};
    if isempty(pix0)
        continue
    end
    [ih,iw,it] = ind2sub([H,W,T],pix0);
    
    rgH = max(min(ih)-gaph,1):min(max(ih)+gaph,H);
    rgW = max(min(iw)-gaph,1):min(max(iw)+gaph,W);
    rgT = max(min(it)-gapt,1):min(max(it)+gapt,T);
    
    dInST = dIn(rgH,rgW,rgT);
    ih1 = ih - min(rgH) + 1;
    iw1 = iw - min(rgW) + 1;
    it1 = it - min(rgT) + 1;
    pix0a = sub2ind(size(dInST),ih1,iw1,it1);
    mskST = false(size(dInST));
    mskST(pix0a) = true;
    mskSTSeed = dMskSeed(rgH,rgW,rgT);
    mskSTSeed = mskST & mskSTSeed;
    
    rgHc{ii} = rgH;
    rgWc{ii} = rgW;
    rgTc{ii} = rgT;
    mskSTc{ii} = mskSTSeed;
    dInSTc{ii} = dInST;
    pixc{ii} = pix0a;
end

% event detection
tic
res = cell(nAR,1);
% for ii=1516
parfor ii=1:nAR
    %if ii==6171; keyboard; else; continue; end
    fprintf('AR %d ----\n',ii)
    %fprintf('AR %d ----\n',arLenOrder(ii))
    dInST = dInSTc{ii};
    mskST = 1*mskSTc{ii};
    T1 = numel(rgTc{ii});
    opts1 = opts;
    opts1.maxStp = max(min(T1-2,opts.maxStp),1);
    res0 = [];
    try
        res0 = burst.detectGrowRegion1(dInST,mskST,pixc{ii},opts1,rgHc{ii},rgWc{ii},rgTc{ii});
    catch
        fprintf('ERROR in region %d\n',ii)
    end
    res{ii} = res0;
end
toc

% put events back to movie
spMap = zeros(H,W,T);
spRec = zeros(H,W,T);
nSPs = 0;
spRise = nan(1,1);
for ii=1:nAR
    res0 = res{ii};
    if ~isempty(res0)
        spMapST = res0.sp;
        if ~isempty(spMapST)
            rgH = res0.rgH;
            rgW = res0.rgW;
            rgT = res0.rgT;
            spMapST(spMapST>0) = spMapST(spMapST>0)+nSPs;
            spMap(rgH,rgW,rgT) = max(spMap(rgH,rgW,rgT),spMapST);
            spRec(rgH,rgW,rgT) = max(spRec(rgH,rgW,rgT),res0.rc);
            spRise(nSPs+1:nSPs+numel(res0.spRise)) = res0.spRise+min(rgT)-1;
            nSPs = nSPs+numel(res0.spRise);
        end
    end
end

end







