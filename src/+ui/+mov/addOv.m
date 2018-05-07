function datxCol = addOv(f,datx,n)

datxCol = zeros(size(datx));
[H,W,~] = size(datx);

scl = getappdata(f,'scl');
btSt = getappdata(f,'btSt');

sclOv = scl.briOv;
if ~strcmp(btSt.overlayDatSel,'None')
    ov = getappdata(f,'ov');
    ov0 = ov(btSt.overlayDatSel);
    x0 = ov0.frame{n};
    c0 = ov0.col;
    
    % remap color
    if isfield(ov0,'colVal') && strcmp(btSt.overlayColorSel,'Random')==0
        v0 = ov0.colVal;
        [~,ix] = min(v0); cmin = c0(ix,:);
        [~,ix] = max(v0); cmax = c0(ix,:);
        for ii=1:numel(v0)
            if v0(ii)<scl.minOv
                c0(ii,:) = cmin;
                continue
            end
            if v0(ii)>scl.maxOv
                c0(ii,:) = cmax;
                continue
            end
            c0(ii,:) = cmin+(v0(ii)-scl.minOv)/(scl.maxOv-scl.minOv)*(cmax-cmin);
        end
    end
    
    % show movie with overlay
    if ~isempty(x0)
        rPlane = zeros(H,W);
        gPlane = rPlane;
        bPlane = rPlane;
        reCon = zeros(H,W);
        for ii=1:numel(x0.idx)
            idx0 = x0.idx(ii);
            if ov0.sel(idx0)>0
                pix0 = x0.pix{ii};
                val0 = x0.val{ii};
                col0 = c0(idx0,:);
                rPlane(pix0) = col0(1);
                gPlane(pix0) = col0(2);
                bPlane(pix0) = col0(3);
                reCon(pix0) = val0;
            end
        end
        datxCol(:,:,1) = rPlane*sclOv.*reCon + datx(:,:,1);
        datxCol(:,:,2) = gPlane*sclOv.*reCon + datx(:,:,2);
        datxCol(:,:,3) = bPlane*sclOv.*reCon + datx(:,:,3);
    end
end

end


