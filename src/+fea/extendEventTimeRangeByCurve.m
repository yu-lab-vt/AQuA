function [dff1,rgT1] = extendEventTimeRangeByCurve(dff,sigxOthers,rgT)

T = numel(dff);

t0 = max(min(rgT)-1,1);
t1 = min(max(rgT)+1,T);

% begin and end of nearest others
if min(rgT)>1
    i0 = find(sigxOthers(1:t0)>0,1,'last');
else
    i0 = [];
end
if max(rgT)<T
    i1 = find(sigxOthers(t1:T)>0,1);
    i1 = i1+t1-1;
else
    i1 = [];
end

% minimum point
if ~isempty(i0)
    [~,ix] = min(dff(i0:min(rgT)));
    t0a = i0+ix-1;
else
    t0a = min(rgT);
end
if ~isempty(i1)
    [~,ix] = min(dff(max(rgT):i1));
    t1a = max(rgT)+ix-1;
else
    t1a = max(rgT);
end
if t0a>=t1a
    t0a = t0;
    t1a = t1;
end

dff1 = dff(t0a:t1a);
rgT1 = t0:t1;

end