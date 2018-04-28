% noise level of average signal
% p0 = 'D:\neuro_WORK\glia_kira\raw_proc\GCaMP_May17\combine\Lck_Gcamp with Aldh1l1-tdtomato\';
% f0 = '1_2_4x_reg_200um_dualwv-001_Cycle00002_Ch1.tif';

p0 = 'D:\neuro_WORK\glia_kira\raw_proc\GCaMP_May17\reg_mix\Lck_Gcamp with Aldh1l1-tdtomato\';
f0 = '1_2_4x_reg_200um_dualwv-001_Cycle00002_Ch1-reg.tif';

dat = double(io.readTiffSeq([p0,f0]));
dat = dat/max(dat(:));

zzshow(dat)
[H,W,T] = size(dat);

dat1 = sqrt(dat);

%%
% x0 = 215; y0 = 316; % signal part
% x0 = 230; y0 = 223; % nosier part
x0 = 117; y0 = 112; % nosier part

gaphw = 0:10;
xVar = nan(numel(gaphw),1);
xVarMed = nan(numel(gaphw),1);
figure;
for ii=1:numel(gaphw)
    dat0 = dat1(y0-gaphw(ii):y0+gaphw(ii),x0-gaphw(ii):x0+gaphw(ii),:);
    dat0vec = reshape(dat0,[],T);
    xm = mean(dat0vec,1);
    xVar(ii) = var(xm(1201:1300));    
    xVarMed(ii) = median((xm(2:end)-xm(1:end-1)).^2)/0.9113;    
    plot(xm+0.1*(ii-1));hold on
end

nS = (gaphw*2+1)'.^2;
xVarTheory = xVar(1)./nS;

figure;plot(-log10(xVar));hold on;plot(-log10(xVarTheory));plot(-log10(xVarMed))

[sqrt(xVar),sqrt(xVarTheory),sqrt(xVarMed)]

xx = randn(1000,10000);
xxVar = median((xx(:,2:end) - xx(:,1:end-1)).^2,2);



