function get2DCorrTable()
    
    sVec = 0:0.01:10;
    cx = sVec*0;
    cy = sVec*0;
    
    sz = [100,100,100];    
    dSim = randn(sz);    
    for ii=1:numel(sVec)
        fprintf('%d\n',ii)
        s00 = sVec(ii);
        if s00>0
            dSimS = imgaussfilt(dSim,[s00 s00]);
        else
            dSimS = dSim;
        end
        dSimZ = zscore(dSimS,0,3);
        rhoxSim = mean(dSimZ(:,1:end-1,:).*dSimZ(:,2:end,:),3);
        rhoySim = mean(dSimZ(1:end-1,:,:).*dSimZ(2:end,:,:),3);
        cx(ii) = nanmedian(rhoxSim(:));
        cy(ii) = nanmedian(rhoySim(:));     
    end
    
    save('./cfg/smoCorr.mat','sVec','cx','cy');
    
end