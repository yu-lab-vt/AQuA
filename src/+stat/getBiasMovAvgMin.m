function getBiasMovAvgMin()
%GETBIASMOVAVGMIN Summary of this function goes here
%   Detailed explanation goes here

N = 10000;
tVec = 100:50:3000;
tBias = tVec*0;
movAvgWin = 25;
for ii=1:numel(tVec)
    T = tVec(ii);
    fprintf('%d\n',T)
    tmp = randn([N,T]);
    tmpMin = min(movmean(tmp,movAvgWin,2),[],2);
    tBias(ii) = mean(tmpMin(:));
end

save('./cfg/movAvgMin.mat','tVec','tBias','movAvgWin');

end

