function [evtRecon,evtL,evtMap,dlyMap,nEvt0,rgtx,rgtSel] = se2evt(...
        dF0,seMap0,seSel,ihw0,rgh,rgw,rgt,it0,T,opts,stg)

gtwSmo = opts.gtwSmo; % 0.5
maxStp = opts.maxStp; % 11
maxRiseUnc = opts.cRise;  % 1
cDelay = opts.cDelay;  % 5

spSz = 25;  % preferred super pixel size
spT = 30;  % super pixel number scale (larger for more)

% GTW on super pixels
% group super pixels to events
if numel(ihw0)>30
    [spLst,cx,dlyMap,distMat,rgtSel,xFail,~,~] = gtw.spgtw(...
        dF0,seMap0,seSel,gtwSmo,maxStp,cDelay,spSz,spT,opts);
    if xFail==0
        % smooth propagation first
        [~,evtMemC,evtMemCMap] = burst.riseMap2evt(spLst,dlyMap,distMat,maxRiseUnc,cDelay,0);
        if 1
            evtMap = zeros(size(dlyMap));
            % detect in each smooth component
            for ii=1:max(evtMemC(:))
                idx0 = evtMemC==ii;
                spLst0 = spLst(idx0);
                distMat0 = distMat(idx0,idx0);
                dlyMap0 = dlyMap;
                dlyMap0(evtMemCMap~=ii) = Inf;
                evtMap00 = burst.riseMap2evt(spLst0,dlyMap0,distMat0,maxRiseUnc,cDelay,1);
                evtMap00(evtMap00>0) = evtMap00(evtMap00>0) + max(evtMap(:));
                evtMap = max(evtMap,evtMap00);
            end
            %figure;imagesc(evtMemCMap);
            %figure;imagesc(evtMap0);
            %keyboard; close all
        end
    end
end

% for small events, do not use GTW
if numel(ihw0)<=30 || xFail==1
    rgtSel = 1:numel(rgt);
    spLst = {ihw0};
    evtMap = zeros(numel(rgh),numel(rgw));
    evtMap(spLst{1}) = 1;
    dlyMap = evtMap;
    dF0Vec = reshape(dF0,[],numel(rgt));
    cx = nanmean(dF0Vec(spLst{1},:),1);
    cx = imgaussfilt(cx,1);
    cx = cx - min(cx);
    cx = cx/nanmax(cx(:));
end

rgtx = min(it0):max(it0);
cxAll = zeros(numel(spLst),T);
cxAll(:,rgt(rgtSel)) = cx;
cx1 = cxAll(:,rgtx);

% events
if ~isfield(opts,'minShow1') || ~isfield(opts,'minShow2')
    minShow = 0.1;
else
    if stg==1
        minShow = opts.minShow1;
    else
        minShow = opts.minShow2;
    end
end
[evtL,evtRecon] = gtw.evtRecon(spLst,cx1,evtMap,minShow);
evtRecon = evtRecon.^2;
evtRecon = uint8(evtRecon*255);
nEvt0 = max(evtL(:));

end

