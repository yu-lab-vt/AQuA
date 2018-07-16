function [c1,v0] = reMapCol(c0,v0,scl)
    
    if ~exist('scl','var')
        scl = [];
        scl.minOv = min(v0);
        scl.maxOv = max(v0);
    end
    
    % clip
    v0(v0<scl.minOv) = scl.minOv;
    v0(v0>scl.maxOv) = scl.maxOv;
    
    nCol = size(c0,1);
    vx = scl.minOv:(scl.maxOv-scl.minOv)/(nCol-1):scl.maxOv;
    c1 = zeros(numel(v0),3);
    for ii=1:numel(v0)
        if v0(ii)<=scl.minOv
            c1(ii,:) = c0(1,:);
            continue
        end
        if v0(ii)>=scl.maxOv
            c1(ii,:) = c0(end,:);
            continue
        end
        if isnan(v0(ii))
            continue
        end
        
        ix0 = find(vx<=v0(ii),1,'last');
        ix1 = find(vx>=v0(ii),1);
        cx0 = c0(ix0,:);
        cx1 = c0(ix1,:);
        vx0 = vx(ix0);
        vx1 = vx(ix1);
        if vx1>vx0  % linear inerpolation
            c1(ii,:) = cx0+(v0(ii)-vx0)/(vx1-vx0)*(cx1-cx0);
        else
            c1(ii,:) = cx0;
        end
    end
    
end