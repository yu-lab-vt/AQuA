function actReg3 = regionMapWithData(regionMap,dat,sclOv,reCon,minSz,minAmp,seedx)
% showActRegion3D draw spatial-temporal FIUs
% use 8 bit for visualization

if ~exist('seedx','var') || isempty(seedx)
    seedx = round(rand()*10000);
end
rng(seedx);

[H,W,T] = size(dat);
dat = uint8(dat*255);
% sclOv = uint8(sclOv);

if ~exist('reCon','var') || isempty(reCon)
    reCon = ones(size(dat));
end

if ~exist('minSz','var') || isempty(minSz)
    minSz = 0;
end

if ~exist('minAmp','var') || isempty(minAmp)
    minAmp = 0;
end

if ~iscell(regionMap)
    rPlane = regionMap*0;
    rgPixLst = label2idx(regionMap);
else
    rPlane = zeros(H,W,T,'uint8');  
    rgPixLst = regionMap;  
end
clear regionMap
gPlane = rPlane;
bPlane = rPlane;

N = length(rgPixLst);
for nn=1:N
    if mod(nn,1000)==0; fprintf('%d\n',nn);end
    tmp = rgPixLst{nn};
    if numel(tmp)<minSz
        continue
    end
    if mean(dat(tmp))<minAmp
        continue
    end
    x = randi(255,[1,3]);
    while (x(1)>0.8*255 && x(2)>0.8*255 && x(3)>0.8*255) || sum(x)<255
        x = randi(255,[1,3]);
    end
    x = uint8(x/max(x)*255);
    rPlane(tmp) = x(1);
    gPlane(tmp) = x(2);
    bPlane(tmp) = x(3);
end

actReg3 = zeros(H,W,3,T,'uint8');
actReg3(:,:,1,:) = uint8(double(rPlane)*sclOv.*reCon) + dat;
actReg3(:,:,2,:) = uint8(double(gPlane)*sclOv.*reCon) + dat;
actReg3(:,:,3,:) = uint8(double(bPlane)*sclOv.*reCon) + dat;

end




