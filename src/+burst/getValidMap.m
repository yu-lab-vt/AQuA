function [validMap,twMap,nNew] = getValidMap(twMap,fiux,pixBad,stg)
% GetValidMap Initial time windows and correlation for each new pixel from neighbors

% dh = [0 0 0 1 -1];
% dw = [0 -1 1 0 0];
dh = [0 -1 0 1 -1 1 -1 0 1];
dw = [0 -1 -1 -1 0 0 1 1 1];

st0 = zeros(3,3); st0(1:3,2)=1; st0(2,1:3)=1;

[H,W] = size(fiux);
validMap = zeros(H,W);
diStep = 1;

mapStart = fiux;
mapStart(pixBad>0) = 0;
nNew = 0;
for kk=1:diStep
    validMapNew = imdilate(mapStart,st0);
    %validMapNew = imdilate(mapStart,strel('square',3));
    if ~stg
        validMapNew = validMapNew - mapStart;        
    end
    nNew = nNew + sum(validMapNew(:));
    validMapNew(pixBad>0) = 0;
    ihw = find(validMapNew);
    [ih,iw] = ind2sub([H,W],ihw);
    twx = zeros(1,4);  % initial time window
    for ii=1:numel(ihw)
        ih0 = ih(ii);
        iw0 = iw(ii);
        for jj=1:numel(dh)
            ih1 = ih0 + dh(jj);
            iw1 = iw0 + dw(jj);
            if ih1<1 || ih1>H || iw1<1 || iw1>W
                continue
            end
            if mapStart(ih1,iw1)>0
                ihw1 = sub2ind([H,W],ih1,iw1);
                twx = twMap(ihw1,:);
                break
            end
        end
        twMap(ihw(ii),:) = twx;
    end
    validMap = validMap + validMapNew;
    mapStart = mapStart + validMapNew;
end

end







