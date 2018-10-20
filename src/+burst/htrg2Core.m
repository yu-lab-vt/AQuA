function [rMap,z] = htrg2Core(zMap,xSeed,xValid,osTb,idx,nConn)
    % htrg2Core implements hypothesis testing region growing for one seed
    % seed can be any region, not just a pixel
    % 
    % TODO: fill holes to make shape better
    % 
    
    M = size(osTb,1);
    
    [H,W] = size(zMap);
    if nConn==8
        dh = [-1 0 1 -1 1 -1 0 1];
        dw = [-1 -1 -1 0 0 1 1 1];
    else
        dh = [0 -1 1 0];
        dw = [-1 0 0 1];
    end
    rMap = zeros(size(zMap));
    
    if numel(xSeed)>1
        seedLst = find(xSeed);
    else
        seedLst = xSeed;
    end
    rMap(seedLst) = idx;
    xValid(seedLst) = 0;
    
    % initialize candidate list
    % for small start region, directly find neighbors instead of dilation
    if numel(xSeed)>1
        bdLst = find(imdilate(xSeed,strel('square',3))-xSeed);        
    else
        [ih0,iw0] = ind2sub([H,W],xSeed);
        ih1 = min(max(ih0+dh,1),H);
        iw1 = min(max(iw0+dw,1),W);
        ihw1 = unique(sub2ind([H,W],ih1,iw1));
        bdLst = ihw1(xValid(ihw1)>0);
    end
    
    % initial z score with order statistics correction
    n0 = numel(seedLst);
    n1 = numel(bdLst);
    bCur = osTb(max(round(n0/(n0+n1)*M),1),2);
    z = (mean(zMap(seedLst)) - bCur)*sqrt(n0);
    
    while ~isempty(bdLst)
        % find best candidate pixel
        [~,ix0] = max(zMap(bdLst));
        ihw0 = bdLst(ix0);
        [ih0,iw0] = ind2sub([H,W],ihw0);
        
        % add neighbors, and remove that candidate
        ih1 = min(max(ih0+dh,1),H);
        iw1 = min(max(iw0+dw,1),W);
        ihw1 = unique(sub2ind([H,W],ih1,iw1));
        ihw1 = ihw1(xValid(ihw1)>0);
        if ~isempty(ihw1)
            bdLst = union(bdLst,ihw1);
        end        
        bdLst = setdiff(bdLst,ihw0);
        
        % update z score with correction
        bPre = osTb(max(round(n0/(n0+n1)*M),1),2);
        zTotCur = (z/sqrt(n0) + bPre)*n0;
        n0 = n0+1;
        n1 = numel(bdLst);
        bCur = osTb(max(round(n0/(n0+n1)*M),1),2);        
        zNew = ( (zTotCur+zMap(ihw0))/n0 - bCur )*sqrt(n0);                
        if zNew<z
            break
        else
            z = zNew;
            rMap(ihw0) = idx;
            xValid(ihw0) = 0;
        end
    end    
end



