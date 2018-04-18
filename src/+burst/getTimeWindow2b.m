function twObj = getTimeWindow2b(x,itS,thr0,df)
%getTimeWindow2B Find a time window for the peak of a seed to baseline

twObj = [];

T = numel(x);

% search forward and backward from peak
% stop if outside active voxels

tPeak = itS;
dfmax = nanmax(df(max(tPeak-1,1):min(tPeak+1,T)));

% need big decrease, if the signal is already bright
thr0 = max(dfmax*0.3,thr0);
% peak0 = nanmax(x(max(tPeak-1,1):min(tPeak+1,T)));

% search for first points lower than threshold
maxOfst1 = 50;
t0 = max(tPeak-maxOfst1,1);
base0 = x(tPeak);
for tt=tPeak:-1:max(tPeak-maxOfst1,1)
    if df(tt)<thr0
        base0 = x(tt);
        t0 = tt;
        break
    end
end

maxOfst2 = 50;
t1 = min(tPeak+maxOfst2,T);
base1 = x(tPeak);
for tt=tPeak:min(tPeak+maxOfst2,T)
    if df(tt)<thr0
        base1 = x(tt);
        t1 = tt;
    end
end

x1 = x; x1(1:max(t0-1,1)) = nan; x1(min(t1+1,T):T) = nan;
[peak0,tPeak] = nanmax(x1);

% balance the base level on left and right
basex = max(base0,base1);
base0 = basex;
base1 = basex;

% 10% and 50% time points
t0z = t0;
for tt=tPeak-1:-1:t0
    if x(tt)-base0 < 0.1*(peak0-base0)
        t0z = tt;
        break
    end
end
t1z = t1;
for tt=tPeak+1:t1
    if x(tt)-base1 < 0.1*(peak0-base1)
        t1z = tt;
        break
    end
end

t0a = t0;
for tt=tPeak-1:-1:t0
    if x(tt)-base0 < 0.5*(peak0-base0)
        t0a = min(tt+1,tPeak);
        break
    end
end
t1a = t1;
for tt=tPeak+1:t1
    if x(tt)-base1 < 0.5*(peak0-base1)
        t1a = max(tt-1,tPeak);
        break
    end
end

if isempty(t0z) || isempty(t1z) || isempty(t0a) || isempty(t1a)
    twObj = [];
    return
end
if t0z>t1z || t0a>t1a
    twObj = [];
    return
end

twObj.t0 = t0z;
twObj.t1 = t1z;
twObj.t0a = t0a;
twObj.t1a = t1a;
twObj.tPeak = tPeak;

end





