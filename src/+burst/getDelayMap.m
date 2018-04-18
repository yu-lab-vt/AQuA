function [dMap,dMapS] = getDelayMap(pathC,txVec,H,W)
%GETDELAYMAP Draw delay map using time points in txVec

dMap = nan(H,W,numel(txVec));
for nn=1:numel(txVec)
    tx = txVec(nn);
%     fprintf('%d\n',nn)
    for ii=1:H
        for jj=1:W
            p0 = pathC{ii,jj};
            if ~isempty(p0)
                p0a = p0(:,1);
                p0b = p0(:,2);
                ix = find(p0a==tx);
                if ~isempty(ix)
                    dMap(ii,jj,nn) = mean(tx-p0b(ix));
                end
            end
        end
    end
end
dMapS = nanmean(dMap,3);

if 0
    figure;imagesc(dMapS);colorbar;
    
    for ii=1:size(dMap,3)
        dMap0 = dMap(:,:,ii);
        figure;imagesc(dMap0);colorbar;
    end
end

end

