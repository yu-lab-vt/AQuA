function lblMapS = sp2evtStp1(lblMapS,riseMap,maxRiseDly1,maxRiseDly2,minOverRate,dat)
% sp2evtStp1 combine superpixels to hyper events

% lblMapSIn = lblMapS;

[H,W,T] = size(lblMapS);
dh = [-1 0 1 -1 1 -1 0 1];
dw = [-1 -1 -1 0 0 1 1 1];

spVoxLst = label2idx(lblMapS);
nSp = numel(spVoxLst);
riseX0 = nan(nSp,1);
for nn=1:nSp
    vox0 = spVoxLst{nn};
    if ~isempty(vox0)
        t0 = double(riseMap(vox0));
        t0 = t0(t0>0);
        riseX0(nn) = nanmedian(t0);
    end
end

% begin with faster propagation
maxRiseDlyVec = maxRiseDly1:maxRiseDly2;
for ee=1:numel(maxRiseDlyVec)
    maxRiseDly0 = maxRiseDlyVec(ee);
    
    % spatial location of super pixel for conflicting
    spPixLst = cell(nSp,1);
    for nn=1:nSp
        vox = spVoxLst{nn};
        [ih,iw,~] = ind2sub([H,W,T],vox);
        spPixLst{nn} = unique(sub2ind([H,W],ih,iw));
    end
    
    % neighbors and conflicts
    lblMapSVec = reshape(lblMapS,[],T);
    neibLst = cell(nSp,1);
    exldLst = cell(nSp,1);
    for nn=1:nSp
        if mod(nn,1000)==0; fprintf('%d\n',nn); end
        vox0 = spVoxLst{nn};
        [ih,iw,it] = ind2sub([H,W,T],vox0);
        neib0 = [];
        for ii=1:numel(dh)
            ih1 = min(max(ih + dh(ii),1),H);
            iw1 = min(max(iw + dw(ii),1),W);
            vox1 = sub2ind([H,W,T],ih1,iw1,it);
            x = lblMapS(vox1);
            idxSel = find(x>0 & x~=nn);
            if ~isempty(idxSel)
                vox1Sel = vox1(idxSel);
                vox0Sel = vox0(idxSel);
                
                % delay difference in boundary pixels
                rise0 = double(riseMap(vox0Sel));
                rise1 = double(riseMap(vox1Sel));
                riseDif = abs(rise0-rise1);  % !! uint16 subtraction gives nonnegative values
                
                xSel = x(idxSel);
                xGood = xSel(riseDif<maxRiseDly0);
                x = unique(xGood);
                if ~isempty(x)
                    neib0 = union(neib0,x);
                end
            end
        end
        neibLst{nn} = neib0;
        
        % conflicting SPs
        ihw = unique(sub2ind([H,W],ih,iw));
        x = lblMapSVec(ihw,:);
        x = x(x>0);
        u = unique(x);
        u = u(u~=nn);
        e0 = [];
        for ii=1:numel(u)
            u1 = u(ii);
            ihw1 = spPixLst{u1};
            nInter = numel(intersect(ihw,ihw1));
			%if (nInter/numel(ihw)>minOverRate || nInter>20) && minOverRate<1
            %if (nInter/numel(ihw)>minOverRate || nInter>20)
            if nInter/numel(ihw)>minOverRate || nInter/numel(ihw1)>minOverRate
                e0 = union(e0,u1);
            end
        end
        exldLst{nn} = e0;
    end
    
    % merge superpixels without conflict
    % earlier one first
    evtLbl = nan(nSp,1);
    [~,dlyOrder] = sort(riseX0,'ascend');
    for ii=1:nSp
        spSeed = dlyOrder(ii);
        if ~isnan(evtLbl(spSeed))
            continue
        end
        %fprintf('%d\n',spSeed)
        newSp = spSeed;
        evtLbl(newSp) = spSeed;
        while 1  % !! too greedy?
            newSp1 = [];
            for jj=1:numel(newSp)
                neib0 = neibLst{newSp(jj)};
                for uu=1:numel(neib0)
                    if isnan(evtLbl(neib0(uu)))
                        exld0 = exldLst{neib0(uu)};
                        if sum(evtLbl(exld0)==spSeed)==0
                            if neib0(uu)==842
                                %keyboard
                            end
                            newSp1 = union(newSp1,neib0(uu));
                        end
                    end
                end
            end
            if isempty(newSp1)
                break
            end
            evtLbl(newSp1) = spSeed;
            newSp = newSp1;
        end
    end
    
    % update super pixel map and rising time
    xx = unique(evtLbl);
    xx = xx(~isnan(xx));
    nSp = numel(xx);
    riseX1 = nan(nSp,1);
    lblMapS1 = zeros(H,W,T,'uint32');
    for ii=1:numel(xx)
        idx = find(evtLbl==xx(ii));
        %riseX1(ii) = nanmean(riseX(idx));
        riseX1(ii) = min(riseX0(idx));
        for jj=1:numel(idx)
            vox0 = spVoxLst{idx(jj)};
            lblMapS1(vox0) = uint32(ii);
        end
    end
    
    %ov1 = plt.regionMapWithData(lblMapS1,dat.^2*0.3,0.5); zzshow(ov1); 
    %pause(0.5); 
    %keyboard
    
    riseX0 = riseX1;
    lblMapS = lblMapS1;
    spVoxLst = label2idx(lblMapS);
end

end


