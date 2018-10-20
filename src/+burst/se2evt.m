function [evtRecon,evtL,evtMap,dlyMap,nEvt0,rgtx,rgtSel] = se2evt(...
        dF0,seMap0,seSel,ihw0,rgh,rgw,rgt,it0,T,opts,~)
    
    gtwSmo = opts.gtwSmo; % 0.5
    maxStp = opts.maxStp; % 11
    maxRiseUnc = opts.cRise;  % 1
    cDelay = opts.cDelay;  % 5
    
    spSz = 16;  % preferred super pixel size. 9.
    spT = 30;  % super pixel number scale (larger for more)
    minProp = 200;  % minimum number of pixels for propagation
    
    % GTW on super pixels
    % group super pixels to events
    xFail = 1;
    if numel(ihw0)>minProp  % FIXME minimum size for propagation
        [spLst,cx,dlyMap,distMat,rgtSel,xFail,~,~] = gtw.spgtw(...
            dF0,seMap0,seSel,gtwSmo,maxStp,cDelay,spSz,spT,opts);
        if xFail==0
            % smooth propagation first
            try
                % FIXME for some reason it only provide part of the events
                % re-run it on un-discovered parts (and label them differently)
                [~,evtMemC,evtMemCMap] = burst.riseMap2evt(spLst,dlyMap,distMat,maxRiseUnc,cDelay,0);
            catch
                warning('SE %d fails',seSel)
                xFail = 1;
            end
            if xFail==0
                evtMap = zeros(size(dlyMap));
                % detect in each smooth component
                for ii=1:max(evtMemC(:))
                    idx0 = evtMemC==ii;
                    spLst0 = spLst(idx0);
                    distMat0 = distMat(idx0,idx0);
                    dlyMap0 = dlyMap;
                    dlyMap0(evtMemCMap~=ii) = Inf;
                    evtMap00 = burst.riseMap2evt(spLst0,dlyMap0,distMat0,maxRiseUnc,cDelay,1);
                    evtMap00(evtMap00>0) = evtMap00(evtMap00>0) + max(evtMap(:));
                    evtMap = max(evtMap,evtMap00);
                end
                % without propagation, and when noise is low, the algorithm fails
                % many parts in the super event will be lost
                if sum(evtMap(:)>0)<0.9*sum(~isinf(dlyMap(:)))
                    fprintf('Skip propagation\n')
                    xFail = 1;
                end
                %zzshow(regionMapWithData(evtMap))
                %keyboard; close all
            end
        end
    end
    
    % for small events, do not use GTW
    if numel(ihw0)<=minProp || xFail==1
        rgtSel = 1:numel(rgt);
        spLst = {ihw0};
        evtMap = zeros(numel(rgh),numel(rgw));
        evtMap(spLst{1}) = 1;
        dlyMap = zeros(size(evtMap));
        dlyMap(spLst{1}) = 0;
        dF0Vec = reshape(dF0,[],numel(rgt));
        cx = nanmean(dF0Vec(spLst{1},:),1);
        %cx = imgaussfilt(cx,1);
        cx = cx - max(min(cx),0);
        cx = cx/nanmax(cx(:));
    end
    
    nFind = max(evtMap(:));
    if nFind>0
        fprintf('Found %d events\n',nFind)
    end
    
    rgtx = min(it0):max(it0);
    cxAll = zeros(numel(spLst),T);
    cxAll(:,rgt(rgtSel)) = cx;
    cx1 = cxAll(:,rgtx);
    
    % events
    if opts.usePG>0
        minShow = sqrt(opts.minShow1);
    else
        minShow = opts.minShow1;
    end
    [evtL,evtRecon] = gtw.evtRecon(spLst,cx1,evtMap,minShow);
    evtRecon = evtRecon.^2;
    evtRecon = uint8(evtRecon*255);
    nEvt0 = max(evtL(:));
    
end

