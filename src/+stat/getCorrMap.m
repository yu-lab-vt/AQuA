function corrMap = getCorrMap( vid, nNeib, dist0 )
%GETCORRMAP8 Compute correlation on each direction of neighbors
% can be 8 or 16

[H,W,~] = size(vid);

if ~exist('nNeib','var')
    nNeib = 8;
end

if nNeib==2
    hofst = [0,0];
    wofst = [-dist0,dist0];
end

if nNeib==8
    hofst = [-1,0,1,-1,1,-1,0,1];
    wofst = [-1,-1,-1,0,0,1,1,1];
end

if nNeib==16
    hofst = [-2:2,repmat([-2,2],1,3),-2:2];
    wofst = [zeros(1,5)-2,-1,-1,0,0,1,1,zeros(1,5)+2];
end

corrMap = nan(H,W,length(hofst));
vidn = vid + randn(size(vid))*1e-6;
for hh=1:H
    if mod(hh,100)==0
        fprintf('%d\n',hh)
    end
    for ww=1:W
        xx = reshape(vidn(hh,ww,:),1,[]);
        for dd=1:length(hofst)
            hh1 = hh + hofst(dd);
            ww1 = ww + wofst(dd);
            if hh1>0 && hh1<=H && ww1>0 && ww1<=W
                yy = reshape(vidn(hh1,ww1,:),1,[]);
                idx0 = ~isnan(xx) & ~isnan(yy);
                x0 = xx(idx0);
                y0 = yy(idx0);
                tmp = corrcoef(x0,y0);
                corrMap(hh,ww,dd) = tmp(1,2);
            end
        end
    end
end


end

