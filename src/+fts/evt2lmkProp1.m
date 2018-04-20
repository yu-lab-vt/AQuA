function res = evt2lmkProp1(datS,lmkMsk)
% distances and directions between events and landmarks
% Multiple threshold frontier based

[H,W,T] = size(datS);
nLmk = numel(lmkMsk);

if H*W*T>100^3
    isBig = 1;
    fprintf('Propagation for landmark ...\n')
else
    isBig = 0;
end

thrRg = 0.2:0.1:0.8;
chgToward = zeros(1,nLmk);
chgAway = zeros(1,nLmk);
chgTowardBefReach = zeros(1,nLmk);
chgAwayAftReach = zeros(1,nLmk);
pixTwd = zeros(H*W,nLmk);
pixAwy = zeros(H*W,nLmk);

for kk=1:numel(thrRg)
    if isBig>0
        fprintf('%d ',kk)
    end
    
    evt0 = datS>thrRg(kk);
    loc0 = find(evt0>0);
    
    % meet an empty event, should not happen
    if isempty(loc0)
        continue
    end
    
    % impute missed frames
    % some times some frame could be missed due to some post processing
    [~,~,it] = ind2sub([H,W,T],loc0);
    tRg = min(it):max(it);
    if numel(tRg)==1
        continue
    end    
    for tt=1:numel(tRg)
        ixSel = it==tRg(tt);
        if isempty(ixSel)
            evt0(:,:,tRg(tt)) = evt0(:,:,tRg(tt)-1);
        end
    end
    
    % distance of valid pixels to landmarks
    % use the center of the landmark
    % use geodesic distance; if landmark outside event, use Euclidean distances
    % keep landmark simple
    D = cell(nLmk,1);
    evt0s = squeeze(sum(evt0,3)>0);
    for ii=1:nLmk
        msk00 = lmkMsk{ii};
        [h0,w0] = find(msk00>0);
        %h00 = mean(h0); w00 = mean(w0);
        %msk00 = zeros(H,W); msk00(max(round(h00),1),max(round(w00),1)) = 1;
        if sum(evt0s(msk00>0))==0
            [h1,w1] = find(evt0s>0);
            tmp = inf(H,W);
            for jj=1:numel(h0)
                dist00 = sqrt((h1-h0(jj)).^2+(w1-w0(jj)).^2);            
                tmp(evt0s>0) = min(tmp(evt0s),dist00);
            end
        else
            tmp = bwdistgeodesic(evt0s,msk00>0);
        end        
        D{ii} = tmp;
    end
    
    % regions and boundaries per frame
    bdLst = cell(numel(tRg),1);  % boundaries in each frame
    lblMap = zeros(H,W,numel(tRg));    
    ccLst = cell(numel(tRg),1);  % region lists in each frame
    for ii=1:numel(tRg)
        xCur = evt0(:,:,tRg(ii));
        [B,L] = bwboundaries(xCur,8,'noholes');
        bdLst{ii} = B;
        lblMap(:,:,ii) = L;
        ccLst{ii} = label2idx(L);
    end

    % frontier change tracking per frame
    dxAllPos = zeros(numel(tRg),nLmk);  % change toward landmark
    dxAllNeg = zeros(numel(tRg),nLmk);  % change away from landmark
    tReach = nan(1,nLmk);  % time for reaching a landmark
    for ii=2:numel(tRg)
        % check reach the landmark or not
        lblCur = lblMap(:,:,ii);
        for jj=1:nLmk
            n11 = sum(lblCur(lmkMsk{jj}>0));
            insideLmk = n11>0;
            if insideLmk && isnan(tReach(jj))
                tReach(jj) = ii;
            end
        end
        
        ccCur = ccLst{ii};
        lblPre = lblMap(:,:,ii-1);
        for jj=1:numel(ccCur)
            % regions in previous frame that connect to this region
            cc0 = ccCur{jj};
            lblSel = unique(lblPre(cc0));
            lblSel = lblSel(lblSel>0);
            if isempty(lblSel)  % this region is new, no propagation
                continue
            end
            
            % previous boundary, the starting point of propagation
            % we use some ad hocs:
            % smaller pre area has higher distance penalty
            % multiple pre area could compete
            % if a previous cc is too small itself relative to current cc, ignore
            % may not be biologically correct, but looks more comfortable
            
            bdPre = [];  % location of the boundaries of previous frame region
            bdPreWt = [];  % boundary weight for choosing propagtion origin
            n0c = numel(cc0);
            for uu=1:numel(lblSel)
                n0 = numel(ccLst{ii-1}{lblSel(uu)});
                if n0>n0c/5
                    tmp = bdLst{ii-1}{lblSel(uu)};
                    tmp = sub2ind([H,W],tmp(:,1),tmp(:,2));
                    bdPre = [bdPre;tmp]; %#ok<AGROW>
                    bdPreWt = [bdPreWt;ones(numel(tmp),1)/n0]; %#ok<AGROW>
                end
            end
            if isempty(bdPre)
                continue
            end
            
            % current boundary, the ending point of propagation
            % do not include boundary that is active in previous frame
            % we only use the incresing signals

            bdCur = ccLst{ii}{jj};            
            bdCur = bdCur(lblPre(bdCur)==0);            
            if isempty(bdCur)
                continue
            end
            
            % link each pixel in bdCur to a pixel in bdPre
            % for each landmark, find the distance change for each pair
            % positive change is toward the landmark
            % if pixCur contains landmark, it is treated as two parts
            dxPos = zeros(numel(bdCur),nLmk);
            dxNeg = zeros(numel(bdCur),nLmk);
            [h0,w0] = ind2sub([H,W],bdCur);
            [h1,w1] = ind2sub([H,W],bdPre);
            for uu=1:numel(bdCur)
                % weighted closest starting frontier point                          
                d00 = sqrt((h0(uu)-h1).^2+(w0(uu)-w1).^2);
                d01 = d00.*bdPreWt;
                [~,ix] = min(d01);
                d00min = d00(ix);                
                
                % find path between points by drawing a line
                h0a = h0(uu); w0a = w0(uu); h1a = h1(ix); w1a = w1(ix);                
                wGap = (w1a-w0a)/max(round(d00min),1);
                hGap = (h1a-h0a)/max(round(d00min),1);
                hx = round(h0a:hGap:h1a);
                wx = round(w0a:wGap:w1a);
                if h0a==h1a && w0a==w1a
                    hx = h0a; wx = w0a;
                elseif h0a==h1a
                    hx = ones(1,numel(wx))*h0a;
                elseif w0a==w1a
                    wx = ones(1,numel(hx))*w0a;
                end                
                hwx = sub2ind([H,W],hx,wx);

                % propagation distance w.r.t. landmarks, per pixel
                for vv=1:nLmk
                    D0 = D{vv};
                    dp0 = D0(hwx);
                    dp0Min = min(dp0);
                    dxPos(uu,vv) = max(D0(h1a,w1a)-dp0Min,0);  % toward
                    dxNeg(uu,vv) = max(D0(h0a,w0a)-dp0Min,0);  % away
                end
            end
            
            % gather pixel level propagation w.r.t. landmarks
            pixTwd(bdCur,:) = pixTwd(bdCur,:)+dxPos;
            pixAwy(bdCur,:) = pixAwy(bdCur,:)+dxNeg;           
                        
            if 0
                lmkSel = 2;
                tmp1 = zeros(H,W); bd1 = bdCur(dxPos(:,lmkSel)>0); tmp1(bd1) = 1;
                tmp2 = zeros(H,W); bd2 = bdCur(dxNeg(:,lmkSel)>0); tmp2(bd2) = 1;
                tmp3 = lmkMsk{vv}*0.3; tmp3(bdPre) = 1;
                tmp = cat(3,tmp1,tmp2,tmp3); figure;imshow(tmp)                
                text(20,20,sprintf('Toward %f - Away %f',...
                    sum(dxPos(:,lmkSel)),sum(dxNeg(:,lmkSel))),'Color','y');
                %pause(2); 
                keyboard
                close
            end
            
            % combine results from pixels
            dxAllPos(ii,:) = dxAllPos(ii,:) + sum(dxPos,1);
            dxAllNeg(ii,:) = dxAllNeg(ii,:) + sum(dxNeg,1);
        end
    end
    
    % combine results from regions
    chgToward = chgToward + sum(dxAllPos,1);
    chgAway = chgAway + sum(dxAllNeg,1);
    
    % split results to before and after reaching landmarks
    for ii=1:nLmk
        if ~isnan(tReach(ii))
            t1 = min(tReach(ii)+1,numel(tRg));
            chgTowardBefReach(ii) = chgTowardBefReach(ii) + sum(dxAllPos(1:tReach(ii),ii));
            chgAwayAftReach(ii) = chgAwayAftReach(ii) + sum(dxAllNeg(t1:end,ii));
        end
    end
end

res.chgToward = chgToward;
res.chgAway = chgAway;
res.chgTowardBefReach = chgTowardBefReach;
res.chgAwayAftReach = chgAwayAftReach;
res.pixelToward = reshape(pixTwd,H,W,nLmk);
res.pixelAway = reshape(pixAwy,H,W,nLmk);

if isBig>0
    fprintf(' OK\n')
end

end







