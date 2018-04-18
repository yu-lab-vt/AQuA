function [corrMap,zMap,zMapDm] = getCorrMapAvg16( vid, validMap, useMean )
%getCorrMapAvg16 compute correlation map
% Avoid direct neighbor
% Support data in two or three dimensions
% Slow implementation, but should be fine for FIUs

mthd = 0;
hofst = [-2:2,repmat([-2,2],1,3),-2:2];
wofst = [zeros(1,5)-2,-1,-1,0,0,1,1,zeros(1,5)+2];
% figure;plot(hofst,wofst)

if ~exist('useMean','var')
    useMean = 0;
end

if length(size(vid))==2
    [nPix,nTps] = size(vid);
    [H,W] = size(validMap);
    [ix,iy] = find(validMap>0);
    vid1 = zeros(H,W,nTps);
    for ii=1:nPix
        vid1(ix(ii),iy(ii),:) = vid(ii,:);
    end    
    vid = vid1;
else
    [H,W,nTps] = size(vid);
end

if ~exist('validMap','var')
    validMap = ones(H,W);
end

corrMap = zeros(H,W);
vidn = vid + randn(size(vid))*1e-6;
for hh=1:H
    if mod(hh,100)==0
        fprintf('%d\n',hh)
    end
    for ww=1:W
        if validMap(hh,ww)==0
            continue
        end
        xx = reshape(vidn(hh,ww,:),1,[]);
        
        % average first, then correlaiton
        if mthd==0
            yym = randn(1,nTps)*1e-6;
            nMet = 0;
            for dd=1:length(hofst)
                hh1 = hh + hofst(dd);
                ww1 = ww + wofst(dd);
                if hh1>0 && hh1<=H && ww1>0 && ww1<=W && validMap(hh1,ww1)>0
                    nMet = nMet + 1;
                    yy = reshape(vidn(hh1,ww1,:),1,[]);
                    yym = yym + yy;
                end
            end
            idx0 = ~isnan(xx) & ~isnan(yym);
            x0 = xx(idx0);
            y0 = yym(idx0);
            %c0 = corrcoef(x0,y0);
            corrMap(hh,ww) = mycorrcoef(x0,y0);
        end
        
        % correlation first, then average
        if mthd==1
            c0 = nan(1,length(hofst));
            for dd=1:length(hofst)
                hh1 = hh + hofst(dd);
                ww1 = ww + wofst(dd);
                if hh1>0 && hh1<=H && ww1>0 && ww1<=W && validMap(hh1,ww1)>0
                    yy = reshape(vidn(hh1,ww1,:),1,[]);                    
                    idx0 = ~isnan(xx) & ~isnan(yy);
                    x0 = xx(idx0);
                    y0 = yy(idx0);
                    %tmp = corrcoef(x0,y0);                    
                    c0(dd) = mycorrcoef(x0,y0);
                end
            end
            if useMean==1
                corrMap(hh,ww) = nanmean(c0);
            else
                corrMap(hh,ww) = nanmax(c0);
            end
        end        
    end
end

% Fisher transform
if useMean==1
    b0 = 0;
else
    b0 = mean(max(randn(10000,16),[],2));
end

zMap = 0.5*log( (1+corrMap)./(1-corrMap))*sqrt(nTps-3)-b0;
zMapDm = zMap - nanmedian(zMap(:));

end

function res=mycorrcoef(x,y)
x = (x - mean(x))/std(x);
y = (y - mean(y))/std(y);
res = mean(x.*y);
end



