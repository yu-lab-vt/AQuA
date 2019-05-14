function [G,neibLst] = evtNeibCorr(mIn,dffMat,tBegin,minCorr,maxTimeDif,bdMap,evtCellLabel)
    % evtNeib detect neighboring events based on curve corrrelation
    % mainly used for merging
    % TODO: use warped curves on boundaries
    
    evtLst = label2idx(mIn);
    N = numel(evtLst);
    [H,W,T] = size(mIn);
    
    dh = [-1 0 1 -1 1 -1 0 1];
    dw = [-1 -1 -1 0 0 1 1 1];
    
    bdLst = label2idx(bdMap);
    
    % neighbors
    neibLst = cell(N,1);
    for nn=1:N
        if mod(nn,1000)==0; fprintf('%d\n',nn); end
        vox0 = evtLst{nn};
        if(isempty(vox0)) 
            continue; 
        end
        [ih,iw,it] = ind2sub([H,W,T],vox0);
        neib0 = [];
        for rr=1:numel(dh)
            ih1 = min(max(ih + dh(rr),1),H);
            iw1 = min(max(iw + dw(rr),1),W);
            cellIndex = evtCellLabel(nn);
            if(cellIndex==0)
                cellRegion = [];
            else
                cellRegion = bdLst{cellIndex};
            end
            vox1 = sub2ind([H,W,T],ih1,iw1,it);
            
            vox12d = sub2ind([H,W],ih1,iw1);
            indx = ismember(vox12d,cellRegion);
            vox1 = vox1(indx);
%             vox1 = intersect(vox1,cellRegion);
            x = mIn(vox1);
            xNeib = unique(x(x>0 & x<nn));
            xNeib = setdiff(xNeib,neib0);
            if ~isempty(xNeib)
                % correlation based or delay based
                c0 = dffMat(nn,:);
                c1 = dffMat(xNeib,:);
                tb0 = tBegin(nn);
                tb1 = tBegin(xNeib);
                ixSig = sum(~isnan([c0;c1]),1)>0;
                t0 = find(ixSig,1);
                t1 = find(ixSig,1,'last');
                c0 = c0(t0:t1);
                c1 = c1(:,t0:t1);
                
                % impute
                T1 = numel(c0);
                for ii=1:(numel(xNeib)+1)
                    if ii==1
                        cx = c0;
                    else
                        cx = c1(ii-1,:);
                    end
                    t0x = find(~isnan(cx),1);
                    t1x = find(~isnan(cx),1,'last');
                    if t0x>1
                        cx(1:t0x-1) = cx(t0x);
                    end
                    if t1x<T1
                        cx(t1x+1:T1) = cx(t1x);
                    end     
                    if ii==1
                        c0 = cx;
                    else
                        c1(ii-1,:) = cx;
                    end               
                end
                                
                % correlation
                x1Good = false(numel(xNeib),1);
                for ii=1:numel(xNeib)
                    c1x = c1(ii,:);
                    tmp = corrcoef(c0,c1x);
                    tDif00 = abs(tb0 - tb1(ii));
                    if tmp(1,2)>minCorr || tDif00<maxTimeDif
                        x1Good(ii) = true;
                    end
                end
                 
                xNeib = xNeib(x1Good);
                if ~isempty(xNeib)
                    neib0 = union(neib0,xNeib);
                end
            end
        end
        neib0 = union(neib0,nn);
        neibLst{nn} = neib0;
    end    
    
    % graph
    s = nan(0,1);
    t = nan(0,1);
    xx = 0;
    for nn=1:N
        neib0 = neibLst{nn};
        if ~isempty(neib0)
            s(xx+1:xx+numel(neib0)) = nn;
            t(xx+1:xx+numel(neib0)) = neib0;
            xx = xx+numel(neib0);
        end
    end
    G = graph(s,t,[],N);
end









