function [lblMapEx,riseX] = getSpDelay(dat,lblMap,opts)
% getSpDelay get the delay of each super pixel

[H,W,T] = size(dat);

datSmo = zeros(size(dat),'single');
for tt=1:T
    datSmo(:,:,tt) = imgaussfilt(dat(:,:,tt),1);
end

K = max(round(T/10),3);
datSmoBase = min(movmean(datSmo,K,3),[],3);
% df = dat - datSmoBase;
dfSmo = datSmo - datSmoBase;

% extend super voxels
if isfield(opts,'extendSV') && opts.extendSV==0
    lblMapEx = lblMap;
else
    lblMapEx = burst.extendVoxGrp(lblMap,dfSmo,ones(size(lblMap),'uint8'),opts.varEst);
end

% rising time
s0 = sqrt(opts.varEst);
thrx = 0:30;
spLst = label2idx(lblMapEx);
nSp = numel(spLst);
riseX = nan(nSp,numel(thrx));

for nn=1:nSp
    if mod(nn,1000)==0; fprintf('%d\n',nn); end
    vox0 = spLst{nn};
    if isempty(vox0)
        continue
    end
    [ih,iw,it] = ind2sub([H,W,T],vox0);
    rgh = min(ih):max(ih);
    rgw = min(iw):max(iw);
    rgt = min(it):max(it);
    df0 = dfSmo(rgh,rgw,rgt);
    mp0 = lblMapEx(rgh,rgw,rgt);
    df0(mp0>0 & mp0~=nn) = 0;
    df0v = reshape(df0,[],numel(rgt));
    x0 = nanmean(df0v);
    
    % estimate noise
    if numel(x0)>5
        s1 = sqrt(median((x0(2:end)-x0(1:end-1)).^2)/0.9133);
    else
        s1 = min(s0/sqrt(size(df0v,1))*3,s0);
    end
    
    % rising time
    for ii=1:numel(thrx)
        thr1 = thrx(ii)*s1;
        t00 = find(x0>thr1,1);
        if ~isempty(t00)
            riseX(nn,ii) = min(rgt)+t00-1;
        else
            break
        end
    end
end

% remove the 0 term
ixLow = find(isnan(riseX(:,2)));
riseX(ixLow,2) = riseX(ixLow,1);
riseX = riseX(:,2:end);

% % remove the 1 term
% ixLow = find(isnan(riseX(:,2)));
% riseX(ixLow,2) = riseX(ixLow,1);
% riseX = riseX(:,2:end);

% riseX0 = riseX(:,1);
% riseX0 = nanmean(riseX(:,1:3),2);
% riseX0 = nanmedian(riseX,2);
% riseMap = zeros(size(dat),'uint16');
% for nn=1:nSp
%     t00 = riseX0(nn);
%     if ~isnan(t00)
%         riseMap(spLst{nn}) = t00;
%     end
% end

end





