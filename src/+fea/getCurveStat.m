function [ rise19,fall91,width55,width11,decayTau,pp ] = getCurveStat( x0,spf,foptions,ignoreTau )
%GETCURVESTAT get rising, falling and half width of a curve, in second
% Input is Delta F/F0

[xPeak,tPeak] = max(x0);

pp = zeros(3,2);  % 10%, 50%, 90% by start/end
thrVec = [0.1,0.5,0.9];
for nn=1:numel(thrVec)
    ix = find(x0<xPeak*thrVec(nn));
    ixPre = ix(ix<=tPeak);
    ixPost = ix(ix>=tPeak);
    if ~isempty(ixPre)
        tPre = max(ixPre);
    else
        tPre = 1;
    end
    if ~isempty(ixPost)
        tPost = min(ixPost);
    else
        tPost = numel(x0);
    end
    pp(nn,1) = tPre;
    pp(nn,2) = tPost;
end

rise19 = (pp(3,1)-pp(1,1)+1)*spf;
fall91 = (pp(1,2)-pp(3,2)+1)*spf;
width55 = (pp(2,2)-pp(2,1))*spf;
width11 = (pp(1,2)-pp(1,1))*spf;

% exponential decay time constant, in ms
y = x0(tPeak:pp(1,2));
decayTau = nan;

if ~isreal(y)
    warning('Curve feature: complex curve\n')
    return
end

if numel(y)>=2 && sum(isnan(y))==0 && sum(isinf(y))==0 && isreal(y) && ignoreTau==0
    y = reshape(double(y),[],1);
    if numel(y)==2
        y = [y;y(end)];
    end
    y = y-min(y);
    y = y/max(y)+0.05;    
    x = (0:1:(numel(y)-1))';
    f = fit(x,y,'exp1',foptions);
    c0 = coeffvalues(f);
    decayTau = -1/c0(2)*spf;
    if decayTau<0 || decayTau>30
        %figure;plot(y);
        fprintf('Decay Tau: %f\n',decayTau)
        %keyboard
    end
end

end











