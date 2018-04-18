function genGaussianOrderTable()
%GENGAUSSIANORDERTABLE 

nMax = 1000;
tbl = cell(nMax,1);
X = randn(10000,nMax);
for ii=1:nMax
    fprintf('%d\n',ii);
    Xs = X(:,1:ii);
    Xs = sort(Xs,2,'descend');
    tbl{ii} = round(mean(Xs,1)*100)/100;
end

save('./cfg/z01Order.mat','tbl');