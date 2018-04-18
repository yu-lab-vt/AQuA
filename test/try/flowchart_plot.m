% save for flowchar
idx = [54,133];
pOut = './tmp/';
rgh = 191:345;
rgw = 191:345;

% raw
imRaw1 = dat(rgh,rgw,idx(1)).^2;
imwrite(imRaw1,[pOut,'raw1.png']);
imRaw2 = dat(rgh,rgw,idx(2)).^2;
imwrite(imRaw2,[pOut,'raw2.png']);

% dF
imdf1 = dF(rgh,rgw,idx(1));
imwrite(imdf1,[pOut,'df1.png']);
imdf2 = dF(rgh,rgw,idx(2));
imwrite(imdf2,[pOut,'df2.png']);

% foreground
imfg1 = dL(rgh,rgw,idx(1));
imfg1 = cat(3,imfg1/4+imRaw1,imRaw1,imRaw1);
imwrite(imfg1,[pOut,'fg1.png']);
imfg2 = dL(rgh,rgw,idx(2));
imfg2 = cat(3,imfg2/4+imRaw2,imRaw2,imRaw2);
imwrite(imfg2,[pOut,'fg2.png']);

% local maximum
lmAll = zeros(H,W,T); 
lmAll(lmLoc) = 1;
lmAll = imdilate(lmAll,strel('square',5));
for idx00 = [idx(1),idx(2)]
    imRaw = dat(rgh,rgw,idx00).^2;
    imfg1 = cat(3,imRaw,imRaw+lmAll(rgh,rgw,idx00),imRaw);
    imwrite(imfg1,[pOut,'lm_',num2str(idx00),'.png']);
end

% initial curves and super voxels
dF0 = dF(260:266,195:201,:);
dF0 = mean(reshape(dF0,[],size(dF,3)),1);
figure;plot(dF0,'LineWidth',3);axis off

ov1 = plt.regionMapWithData(lblMapS,dat.^2,0.25);
imSp1 = ov1(rgh,rgw,:,idx(1));
imwrite(imSp1,[pOut,'sp1.png']);
imSp2 = ov1(rgh,rgw,:,idx(2));
imwrite(imSp2,[pOut,'sp2.png']);

%% super events and events
ov2 = plt.regionMapWithData(lblMapC1,dat.^2*0.3,0.25);
imSe1 = ov2(rgh,rgw,:,idx(1));
imwrite(imSe1,[pOut,'se1.png']);
imSe2 = ov2(rgh,rgw,:,idx(2));
imwrite(imSe2,[pOut,'se2.png']);

if 1
    pOut = './tmp/';
    rgh = 191:345;
    rgw = 191:345;
    
    tMapxx = spDlyMap1; 
    %tMapxx(mskOut>0) = nan; 
    tMapxx(tMapxx>35) = 35;
    tMapxx = tMapxx(rgh,rgw);
    figure;imagesc(tMapxx,'AlphaData',~isnan(tMapxx));colorbar;axis off
    
    dFxM = nanmean(dFx,3);
    evtLmOrg = cat(3,dFxM+lm0,dFxM,dFxM);
    imwrite(evtLmOrg(rgh,rgw,:),[pOut,'evtLmOrg.png']);
    evtLmFt = cat(3,dFxM+lm1,dFxM,dFxM);
    imwrite(evtLmFt(rgh,rgw,:),[pOut,'evtLmFt.png']);
end

ov3 = plt.regionMapWithData(lblMapC,dat.^2*0.3,0.25);
imEvt1 = ov3(rgh,rgw,:,idx(1));
imwrite(imEvt1,[pOut,'evt1.png']);
imEvt2 = ov3(rgh,rgw,:,idx(2));
imwrite(imEvt2,[pOut,'evt2.png']);













