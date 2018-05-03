function df0ip = imputeMovVec(df0)

[N,T] = size(df0);

df0ip = df0;
for ii=1:N
    x0 = squeeze(df0(ii,:));
    for tt=2:T
        if isnan(x0(tt))
            x0(tt) = x0(tt-1);
        end
    end
    for tt=T-1:-1:1
        if isnan(x0(tt))
            x0(tt) = x0(tt+1);
        end
    end
    x0i = x0;
    df0ip(ii,:) = x0i;
end
df0ip(isnan(df0ip)) = 0;

end