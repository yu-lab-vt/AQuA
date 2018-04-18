T = 75;

x0 = [0:0.1:1,1,1,1,1,1:-0.2:0];
x1 = [0:0.2:1,1,1,0.6,0.2,0];
x = zeros(1,T);

dat = zeros(10,T);

% event 1
for ii=2:6
    tmp = zeros(1,T);
    t0 = 5+ii*2;
    t1 = t0+numel(x0)-1;
    tmp(t0:t1) = x0*(-0.08*ii+1.16);
    dat(ii,:) = dat(ii,:)+tmp;
end

for ii=10:-1:7
    tmp = zeros(1,T);
    t0 = 5+(12-ii)*2;
    t1 = t0+numel(x0)-1;
    tmp(t0:t1) = x0*(-0.08*(12-ii)+1.16);
    dat(ii,:) = dat(ii,:)+tmp;
end

% event 2
for ii=4:8
    tmp = zeros(1,T);
    t0 = 22+ii*2;
    t1 = t0+numel(x0)-1;
    tmp(t0:t1) = x0*0.5;
    dat(ii,:) = dat(ii,:)+tmp;
end

% % event 3
% for ii=7:10
%     tmp = zeros(1,T);
%     t0 = 3;
%     t1 = t0+numel(x1)-1;
%     tmp(t0:t1) = x1;
%     dat(ii,:) = dat(ii,:)+tmp;
% end

% event 4
for ii=1:10
    tmp = zeros(1,T);
    t0 = 55+round(randn()/1.5);
    t1 = t0+numel(x1)-1;
    tmp(t0:t1) = x1;
    dat(ii,:) = dat(ii,:)+tmp;
end

%
figure;
dat = dat + randn(size(dat))*0.06;
for ii=1:10
    tmp = dat(ii,:);
    plot(tmp*0.8+11-ii,'b');hold on
end
axis([-10,80,0,11])
grid off



