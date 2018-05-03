function [riseLst,datR,datL,seMap] = evtTop(dat,dF,lblMapS,riseMap,opts,ff)
% evtTop super voxels to super events and optionally, to events

gtwSmo = opts.gtwSmo; % 0.5
maxStp = opts.maxStp; % 11
maxRiseUnc = opts.cRise;  % 1
cDelay = opts.cDelay;  % 5

spSz = 25;  % preferred super pixel size
spT = 30;  % super pixel number scale (larger for more)

[H,W,T] = size(dat);

% datMA = movmean(dat,ceil(T/5),3);
% datBase = min(datMA,[],3);
% dF = dat-datBase;

% super voxels to super events
fprintf('Detecting super events ...\n')
if opts.superEventdensityFirst==1
    [neibLst,exldLst] = burst.svNeib(lblMapS,riseMap,5,0.2);
    seMap = burst.sv2se(lblMapS,neibLst,exldLst);
else
    xx = double(riseMap); xx(xx==0) = nan;
    seMap = burst.sp2evtStp1(lblMapS,xx,0,10,0.2,dat);
end
c1x = label2idx(seMap);
if exist('ff','var')
    waitbar(0.2,ff);
end

% load('D:\neuro_WORK\glia_kira\tmp\ttx_test_20180426\matlab.mat');

% super event to events
fprintf('Detecting events ...\n')
% [~,seSel] = nanmax(cellfun(@numel,c1x));
riseLst = cell(0);
datR = zeros(H,W,T,'uint8');
datL = zeros(H,W,T);
nEvt = 0;
for nn=1:numel(c1x)
    se0 = c1x{nn};
    if isempty(se0)
        continue
    end
    fprintf('SE %d \n',nn)
    if exist('ff','var')
        waitbar(0.2+nn/numel(c1x)*0.55,ff);
    end    
    
    [ih0,iw0,it0] = ind2sub([H,W,T],se0);    
    rgh = min(ih0):max(ih0);
    rgw = min(iw0):max(iw0);
    ihw0 = unique(sub2ind([numel(rgh),numel(rgw)],ih0-min(rgh)+1,iw0-min(rgw)+1));
    gapt = max(max(it0)-min(it0),5);
    rgt = max(min(it0)-gapt,1):min(max(it0)+gapt,T);    
    dF0 = double(dF(rgh,rgw,rgt));
    seMap0 = seMap(rgh,rgw,rgt);
    seSel = nn;
    xFail = 0;
    
    % GTW on super pixels
    % group super pixels to events
    if numel(ihw0)>30
        [spLst,cx,dlyMap,distMat,rgtSel,xFail,~,~] = gtw.spgtw(dF0,seMap0,seSel,gtwSmo,maxStp,cDelay,spSz,spT);
        if xFail==0
            [evtMap0,evtMemC,evtMemCMap] = burst.riseMap2evt(spLst,dlyMap,distMat,maxRiseUnc,cDelay,0);
            if 1
                evtMap0 = zeros(size(dlyMap));
                for ii=1:max(evtMemC(:))
                    idx0 = evtMemC==ii;
                    spLst0 = spLst(idx0);
                    distMat0 = distMat(idx0,idx0);
                    dlyMap0 = dlyMap;
                    dlyMap0(evtMemCMap~=ii) = Inf;
                    evtMap00 = burst.riseMap2evt(spLst0,dlyMap0,distMat0,maxRiseUnc,cDelay,1);
                    evtMap00(evtMap00>0) = evtMap00(evtMap00>0) + max(evtMap0(:));
                    evtMap0 = max(evtMap0,evtMap00);
                end
                %figure;imagesc(evtMemCMap);
                %figure;imagesc(evtMap0);
                %keyboard; close all                
            end
        end
    end

    % for small events, do not use GTW
    if numel(ihw0)<=30 || xFail==1
        dlyMap = [];
        rgtSel = 1:numel(rgt);
        spLst = {ihw0};
        evtMap0 = zeros(numel(rgh),numel(rgw));
        evtMap0(spLst{1}) = 1;
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
    [evtL,evtRecon] = gtw.evtRecon(spLst,cx1,evtMap0);
    evtRecon = evtRecon.^2;
    evtRecon = uint8(evtRecon*255);
    nEvt0 = max(evtL(:));
    evtL(evtL>0) = evtL(evtL>0)+nEvt;
    
    dLNow = datL(rgh,rgw,rgtx);
    dRNow = datR(rgh,rgw,rgtx);
    
    ixOld = evtRecon<dRNow;
    evtL(ixOld) = dLNow(ixOld);

    datR(rgh,rgw,rgtx) = max(datR(rgh,rgw,rgtx),evtRecon);
    datL(rgh,rgw,rgtx) = evtL;
    
    nEvt = nEvt + nEvt0;
    
    riseLst{nn} = dlyMap;
    
    if mod(nn,50)==0
        fprintf('');
    end    
end

% ov1 = plt.regionMapWithData(spLst,zeros(H,W),0.3); zzshow(ov1);
% ov2 = plt.regionMapWithData(evtMap0,evtMap0*0,0.5); zzshow(ov2);

% merge and filter small events
datL = burst.mergeEvt(datL,opts.mergeEventDiscon);
if exist('ff','var')
    waitbar(0.8,ff);
end

end



