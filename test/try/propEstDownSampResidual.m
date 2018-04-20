% downsample, GTW, upsample, and residual
H1 = 64;
W1 = 64;
dfx = df0(:,:,1:90);
[H,W,T1] = size(dfx);
dat = zeros(H1,W1,T1);
for tt=1:T1
    tmp = dfx(:,:,tt);
    dat(:,:,tt) = imresize(tmp,[H1,W1]);
end
validMap = ones(H1,W1);

%%
x0 = dat(40,40,:); figure;plot(x0(:))

%%
opts0 = opts;
opts0.gtwSmo = 0.5;
opts0.varEst = opts.varEst/5;
opts0.maxStp = 10;
tic
res = burst.fitOnCr1(dat,opts0,validMap);
toc

zzshow(res.datWarp)
zzshow(res.datRec)

datRec = zeros(H,W,T1);
for tt=1:T1
    tmp = res.datRec(:,:,tt);
    datRec(:,:,tt) = imresize(tmp,[H,W]);
end
zzshow(datRec)
