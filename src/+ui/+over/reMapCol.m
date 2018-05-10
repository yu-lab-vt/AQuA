function [c0,v0] = reMapCol(c0,v0,scl)

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

v0(v0<scl.minOv) = scl.minOv;
v0(v0>scl.maxOv) = scl.maxOv;

end