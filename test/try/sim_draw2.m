T = 20;

x0 = [0:0.1:1,1,1,1,1,1:-0.2:0];
x1 = [0:0.2:1,1,1,0.6,0.2,0];
x = zeros(1,T);

dat = zeros(10,T);

% % event 1
% for ii=3:7
%     tmp = zeros(1,T);
%     t0 = 10;
%     t1 = t0+numel(x1)-1;
%     tmp(t0:t1) = x1*(1.5-0.2*(abs(5-ii))^2);
%     dat(ii,:) = dat(ii,:)+tmp;
% end

% event 2
for ii=1:10
    tmp = zeros(1,T);
    t0 = 5;
    t1 = t0+numel(x1)-1;
    tmp(t0:t1) = x1*(1.5-0.2*(abs(5-ii))^1.05);
    dat(ii,:) = max(dat(ii,:),tmp);
end

%
figure;
dat = dat + randn(size(dat))*0.06;
for ii=1:10
    tmp = dat(ii,:);
    plot(tmp*0.8+11-ii,'b');hold on
end
axis([0,20,0,11])
grid off



