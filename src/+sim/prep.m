function [dat,datOrg,validMap,opts] = prepSim(id,varEst)
% prepSim generates simulation data

opts = util.parseParam(1);
opts.usePG = 0;
opts.varEst = varEst;

H = 64; 
W = 64;

if id==1  % simulation, one large event, no propagation
    x = [0 0 0 0.1 0.3 0.5 0.7 0.9 1 0.75 0.5 0.25 0 0 0];
    xRef = [x,zeros(1,3)];
    xExt = [zeros(1,3),x];
    T = numel(xRef);
    dat2d = repmat(xExt,H*W,1);
    dat = reshape(dat2d,[H,W,T])*0.3;
    validMap = ones(H,W);
end

if id==2  % simulation, multiple events, no propagation
    x = [0 0.1 0.3 0.4 0.5 0.7 0.9 1 0.9 0.7 0.5 0.5 0.4 0.3 0.2 0];  % background
    xEvt = [0 0.5 1 0.5 0];  % events
    T = 30;
    dat = zeros(H,W,T);
    evtsMap = fiuts.divideRegionSeed( ones(H,W), 1, 4 );
    for ii=1:max(evtsMap(:))
        if rand()<0.8
            evtsMap(evtsMap==ii) = 0;
        end
    end    
    %figure;imshow(label2rgb(evtsMap,'jet','k','shuffle'))
    nEvts = max(evtsMap(:));
    delayVec = randi(7,[1,nEvts])-4;
    for hh=1:H
        for ww=1:W
            tmp = zeros(1,T);
            tmp(5:5+numel(x)-1) = x/3;
            idx = evtsMap(hh,ww);
            if idx>0
                dly = delayVec(idx);
                rgEvt = 11+dly:11+dly+numel(xEvt)-1;
                tmp(rgEvt) = tmp(rgEvt) + xEvt/3;
            end
            dat(hh,ww,:) = tmp;
        end
    end
    validMap = ones(H,W);
end

if id==3  % simulation, multiple events, no propagation in events, propagation in background
    t0 = 10; t1 = 22; 
    sampRate = 10;
    T = 50;
    x = [0 0.1 0.3 0.4 0.5 0.7 0.9 ones(1,7) 0.9 0.7 0.5 0.5 0.4 0.3 0.2 0];
    xEvt = [0 0.5 1 0.5 0];
    
    xUp = interp(x,sampRate);
    dat = zeros(H,W,T);
    evtsMap = fiuts.divideRegionSeed( ones(H,W), 1, 4 );
    %figure;imshow(label2rgb(evtsMap,'jet','k','shuffle'))
    nEvts = max(evtsMap(:));
    delayVec = randi(13,[1,nEvts])-7;
    for hh=1:H
        for ww=1:W
            tmp = zeros(1,T);
            xDly = downsample([zeros(1,hh),xUp],sampRate);
            tmp(t0:t0+numel(xDly)-1) = xDly/3;
            idx = evtsMap(hh,ww);
            dly = delayVec(idx);
            rgEvt = t1+dly:t1+dly+numel(xEvt)-1;
            tmp(rgEvt) = tmp(rgEvt) + xEvt/3;
            dat(hh,ww,:) = tmp;
        end
    end
    validMap = ones(H,W);
end

if id==4  % test fitting bias
    x = [0 0 0 0.1 0.3 0.5 0.7 1 0.75 0.5 0.25 0 0 0 0 0 0];
    x1 = [0 0 0 0.1 0.3 0.5 0.7 1 0.75 0.5 0.25 0 0 0 0.5 0.5 0];
    xExt = reshape([zeros(1,3),x],1,1,[]);
    x1Ext = reshape([zeros(1,3),x1],1,1,[]);
    T = numel(xExt);
    xN = xExt*0;
    datA = repmat(xExt,H/2,W/2);
    datB = repmat(x1Ext,H/2,W/2);
    datC = repmat(xN,H/2,W,1);
    dat = cat(1,cat(2,datA,datB),datC)*0.5;
    %dat = reshape(dat2d,[H,W,T])*0.3;
    validMap = ones(H,W);
end

datOrg = dat;
dat = dat + randn(H,W,T)*sqrt(varEst);

end




