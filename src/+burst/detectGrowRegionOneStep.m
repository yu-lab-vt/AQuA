function [resCell,lblMap] = detectGrowRegionOneStep(...
    dat,datSmo,resCell,lblMap,lmLoc,lmVal,lm3Idx,mskSig,opts,thrx,stg)
% detectGrowRegionOneStep grow all seeds by one step
% compete between seeds

[~,lmOrder] = sort(lmVal,'descend');
[H,W,T] = size(dat);
if numel(lmVal)>100; fprintf('Loop '); end

for uu=1:numel(lmVal)
%     if uu==8
    if sum(lmOrder(uu)==1470)>0
%         keyboard;
    else
%         continue
    end
    if mod(uu,100)==0
        fprintf('%d ',uu)
    end

    iSeed = lmLoc(lmOrder(uu));
    if lm3Idx(iSeed)==0  % eaten by others
        continue
    end
    [ihS,iwS,itS] = ind2sub([H,W,T],iSeed);
    
    if stg==0  % time window detection and curve initialization        
        rgH1 = max(ihS-1,1):min(ihS+1,H); rgW1 = max(iwS-1,1):min(iwS+1,W);
        rgH2 = max(ihS-2,1):min(ihS+2,H); rgW2 = max(iwS-2,1):min(iwS+2,W);
        x1 = mean(reshape(dat(rgH1,rgW1,:),[],T),1);
        z1 = max(reshape(lm3Idx(rgH2,rgW2,:),[],T),[],1);
        b1 = mean(reshape(datSmo(rgH1,rgW1,:),[],T),1);
        tw1 = burst.getTimeWindow2a(x1,itS,1,thrx,z1,b1);
        if isempty(tw1)  % seeds need to be merged, try again
            tw1 = burst.getTimeWindow2a(x1,itS,1,thrx,z1*0,b1);
        end
        if isempty(tw1)
            lm3Idx(iSeed) = 0;
            continue
        end
        lm3Idx(rgH2,rgW2,tw1.t0a:tw1.t1a) = 0;
        res = []; %res.charxIno = x1o;
        res.charxIn = x1; res.tw = tw1; res.iSeed = iSeed; res.stg = 0;
        res = burst.detectGrowEvent(dat,datSmo,res,opts,1);
    else  % growing
        res = resCell{lmOrder(uu)};
        if isempty(res)
            continue
        end
        res = burst.detectGrowEvent(dat,datSmo,res,opts,1);
    end
    
    % update active voxel and signal variance maps
    if ~isempty(res.pixNew)
        for ii=1:numel(res.pixNew)
            ix0 = res.pixNew(ii);
            ihw0 = res.fiux(ix0);
            [ih0,iw0] = ind2sub([H,W],ihw0);
            twx = res.twMap(ix0,:);
            if twx(1)==0
                continue
            end

            %lblCur = lblMap(ih0,iw0,twx(5));
            lblCur = lblMap(ih0,iw0,twx(3):twx(4));
            sigCur = mskSig(ih0,iw0,twx(3):twx(4));
            %lblCur = lblMap(ih0,iw0,max(twx(3)-1,1):min(twx(4)+1,T));
            isGood = nanmax(lblCur)==0 && sum(sigCur>0)>0;
            if isGood  % ignore competition
                lblCur = lblMap(ih0,iw0,twx(3):twx(4));
                t0 = find(lblCur(1:twx(5)-twx(3)+1)>0,1,'last');
                t1 = find(lblCur(twx(5)-twx(3)+1:end)>0,1);
                if isempty(t0)
                    t0 = 1;
                end
                if isempty(t1)
                    t1 = numel(lblCur);
                else
                    t1 = twx(5)-twx(3)+1+t1-1;
                end                
                lblCur(t0:t1) = lblCur(t0:t1)*0+lmOrder(uu);
                lblMap(ih0,iw0,twx(3):twx(4)) = lblCur;
            else  % lose the competition
                res.pixBad = union(res.pixBad,ihw0);
            end
        end
    end
    resCell{lmOrder(uu)} = res;
end

if numel(lmVal)>100; fprintf('\n'); end

end




