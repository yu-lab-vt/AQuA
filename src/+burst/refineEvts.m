function [evts,zVec] = refineEvts(dF,evtLst,opts,stdEst,showMe)
    % refineEvts use region growing to refine super events
    % dat: input data in delta F
    % evtLst: super events list
    % delta: dilation/erosion filter size for refinement range
    %
    
    if ~exist('showMe','var')
        showMe = 0;
    end
    delta = 2*ceil(2*opts.smoXY)+1;
    
    % get noise level
    [H,W,T] = size(dF);
    if ~exist('stdEst','var')
        xx = (dF(:,:,2:end)-dF(:,:,1:end-1)).^2;
        stdMap = sqrt(median(xx,3)/0.9133);
        stdEst = double(nanmedian(stdMap(:)));
    end
    
    % temporal processing
    evtMap = img.lst2map(evtLst,opts.sz);
    if opts.htrgSmoZ>0
        %evtMapVec = reshape(evtMap,[],size(evtMap,3));
        dFVec = reshape(dF,[],size(dF,3));
        dh = 5;
        %gk = fspecial('gaussian',[1,2*dh+1],2);
        gk = fspecial('gaussian',[1,2*dh+1],opts.smoXY*2);
        %m0 = mean(dF(evtMap==0));
        parfor ii=1:size(dFVec,1)
            x0 = dFVec(ii,:);
            %e0 = evtMapVec(ii,:);
            x0 = [ones(1,dh)*mean(x0(1:dh)),x0,ones(1,dh)*mean(x0(end-dh+1:end))]
            x1 = conv(x0,gk);
            x1 = x1( (2*dh+1):(end-dh*2) );
            %m0 = mean(x0);
            %x1(x1<m0) = 0;
            dFVec(ii,:) = x1;
        end
        dF = reshape(dFVec,opts.sz);
    end

    evts = cell(numel(evtLst,1));
    %evtMap = lst2map(evtLst,size(dat));
    
    zVec = nan(numel(evtLst),1);
    
    for nn=1:numel(evtLst)
        if mod(nn,100)==0; fprintf('%d\n',nn); end        
        pix0 = evtLst{nn};
        if isempty(pix0)
            continue
        end
        
        [ih,iw,it] = ind2sub([H,W,T],pix0);
        rgh = max(min(ih)-5,1):min(max(ih)+5,H);
        rgw = max(min(iw)-5,1):min(max(iw)+5,W);
        t00 = max(ceil( (max(it)-min(it)+1)/2 ),3);  % make correlation balanced
        %t00 = 20;
        rgt = max(min(it)-t00,1):min(max(it)+t00,T);
        d0 = dF(rgh,rgw,rgt);
        e0 = evtMap(rgh,rgw,rgt);
        
        % refine region
        [vox1,htMap0a,fiu0,z0] = burst.refineRegion(d0,e0,nn,stdEst,delta,...
            opts.osTb,opts.htrgSolver,opts.htrgSeed,opts.htrgClean);
        zVec(nn) = z0;
        
        if showMe
            figure;subplot(1,2,1);imshow(htMap0a);subplot(1,2,2);imshow(fiu0);
        end

        if ~isempty(vox1)
            [ih2,iw2,it2] = ind2sub(size(e0),vox1);
            ih2a = ih2+min(rgh)-1;
            iw2a = iw2+min(rgw)-1;
            it2a = it2+min(rgt)-1;
            evts{nn} = sub2ind([H,W,T],ih2a,iw2a,it2a);
        end
    end
end





