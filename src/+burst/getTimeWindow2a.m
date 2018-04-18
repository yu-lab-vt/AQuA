function twObj = getTimeWindow2a(x,itS,thr0,otherSeeds,df)
%GETTIMEWINDOW2A Find a compact time window for the peak of a seed

twObj = [];

T = numel(x);
stg = 1;

% if stg==0
%     thr = 1e8;
% end

% search forward and backward from peak
% stop if outside active voxels
% stop if meet a rising in forward searching or a falling in backward searching

tPeak = itS;
dfmax = nanmax(df(max(tPeak-1,1):min(tPeak+1,T)));
if dfmax < thr0
    return
end

% need big decrease, if the signal is already bright
thr = max(dfmax*0.3,thr0);
peak0 = nanmax(x(max(tPeak-1,1):min(tPeak+1,T)));

% time window (search space)
maxOfst1 = find(otherSeeds(1:tPeak-1),1,'last');
if isempty(maxOfst1)
    maxOfst1 = 50;
else
    maxOfst1 = tPeak - maxOfst1;
end
maxOfst2 = find(otherSeeds(tPeak+1:end),1);
if isempty(maxOfst2)
    maxOfst2 = 50;
end

% search for point lower than threshold
t0 = max(tPeak-maxOfst1,1);
st0 = 0;
base0 = x(tPeak);
iMin = tPeak;
% t0d = 1;
for tt=tPeak:-1:max(tPeak-maxOfst1,1)
    if x(tt)<base0
        base0 = x(tt);
        iMin = tt;
    end
    if x(tt)>peak0 && stg==1
        t0 = iMin;
        break
    end
    if peak0-x(tt)>thr
        %         t0d = tt;
        st0 = 1;
    end
    if x(tt)-base0>thr && st0==1
        t0 = iMin;
        break
    end
    if isnan(x(tt))
        t0 = tt;
        break
    end
end

t1 = min(tPeak+maxOfst2,T);
st0 = 0;
base1 = x(tPeak);
iMin = tPeak;
% t1d = T;
for tt=tPeak:min(tPeak+maxOfst2,T)
    if x(tt)<base1
        base1 = x(tt);
        iMin = tt;
    end
    if x(tt)>peak0 && stg==1
        t1 = iMin;
        break
    end
    if peak0-x(tt)>thr
        %         t1d = tt;
        st0 = 1;
    end
    if x(tt)-base1>thr && st0==1
        t1 = iMin;
        break
    end
    if isnan(x(tt))
        t1 = tt;
        break
    end
end

% update peak
x1 = x; x1(1:max(t0-1,1)) = nan; x1(min(t1+1,T):T) = nan;
[peak0,tPeak] = nanmax(x1);

% balance the base level on left and right
basex = max(base0,base1);
base0 = basex;
base1 = basex;

% find 10% and 50% points
% if stg==1
if peak0-base0<thr || peak0-base1<thr
    return
end
% end

t0z = t0;
for tt=tPeak-1:-1:t0
    if x(tt)-base0 < 0.1*(peak0-base0) && (peak0-x(tt))>thr
        t0z = tt;
        break
    end
end
t1z = t1;
for tt=tPeak+1:t1
    if x(tt)-base1 < 0.1*(peak0-base1) && (peak0-x(tt))>thr
        t1z = tt;
        break
    end
end

t0a = t0;
for tt=tPeak-1:-1:t0
    if x(tt)-base0 < 0.5*(peak0-base0) && (peak0-x(tt))>thr
        t0a = min(max(t0+1,tt),tPeak);
        break
    end
end
t1a = t1;
for tt=tPeak+1:t1
    if x(tt)-base1 < 0.5*(peak0-base1) && (peak0-x(tt))>thr
        t1a = max(min(t1-1,tt),tPeak);
        break
    end
end

% use significant drop points if they are more compact
% t0z = max(max(t0d-1,t0z),t0a-1);
% t1z = min(min(t1d+1,t1z),t1a+1);
% t0a = max(t0d,t0a);
% t1a = min(t1d,t1a);

if isempty(t0z) || isempty(t1z) || isempty(t0a) || isempty(t1a)
    twObj = [];
    return
    %     keyboard
end
if t0z>t1z || t0a>t1a
    twObj = [];
    return
    %     keyboard
end

twObj.t0 = t0z;
twObj.t1 = t1z;
twObj.t0a = t0a;
twObj.t1a = t1a;
twObj.tPeak = tPeak;

% if peak0-base0<thr || peak0-base1<thr
%     twObj = [];
% end

end





