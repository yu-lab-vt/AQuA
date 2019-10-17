function [riseLst,datR,evtLst,seLst] = evtTop(dat,dF,svLst,riseX,opts,ff,bd,f)
    % evtTop super voxels to super events and optionally, to events
    
    [H,W,T] = size(dat);
    
    if isfield(opts,'gapExt')
        gaptxx = opts.gapExt;  % 5 by default
    else
        gaptxx = 50;
    end
    
    if(exist('f'))
       fh = guidata(f); 
    end
    
    lblMapS = zeros(size(dat),'uint32');
    for nn=1:numel(svLst)
        lblMapS(svLst{nn}) = nn;
    end
    riseMap = zeros(size(dat),'uint16');    
    riseX0 = nanmedian(riseX,2);
    for nn=1:numel(svLst)
        t00 = riseX0(nn);
        if ~isnan(t00)
            riseMap(svLst{nn}) = t00;
        end
    end
%     for nn=1:numel(svLst)
%         t00 = riseX(nn,:);
%         if sum(~isnan(t00))>0
%             t00a = t00(~isnan(t00));
%             t00b = median(t00a(round(numel(t00a)/2):end));
%             riseMap(svLst{nn}) = t00b;
%         end
%     end    
    
    % super voxels to super events
    fprintf('Detecting super events ...\n')
    stp11 = max(round(opts.maxStp/2),2);
    if opts.superEventdensityFirst==1
        [neibLst,exldLst] = burst.svNeib(lblMapS,riseMap,stp11,opts.cOver);
        seMap = burst.sv2se(lblMapS,neibLst,exldLst);
    else
        xx = double(riseMap); xx(xx==0) = nan;
        seMap = burst.sp2evtStp1(lblMapS,xx,0,stp11,0.2,dat);
    end
    
    % seperate events in different region
    if exist('bd')==1 && ~isempty(bd)
        seMap = burst.seperateEvents(seMap,bd);
    end
    
    seLst = label2idx(seMap);
    % filter small super events
    size2d = zeros(numel(seLst),1);
    for i = 1:numel(seLst)
        [ih,iw,it] = ind2sub([H,W,T],seLst{i});
        size2d(i) = numel(unique(sub2ind([H,W],ih,iw)));
    end
    filter = size2d>opts.minSize;
    seLst = seLst(filter);
    % update seMap
    seMap = zeros([H,W,T]);
    for i = 1:numel(seLst)
        seMap(seLst{i}) = i;
    end
    if exist('ff','var') && ~isempty(ff)
        waitbar(0.2,ff);
    end
    
    % super event to events
    fprintf('Detecting events ...\n')
    riseLst = cell(0);
    datR = zeros(H,W,T,'uint8');
    datL = zeros(H,W,T);
    nEvt = 0;
    for nn=1:numel(seLst)
        se0 = seLst{nn};
        if isempty(se0)
            continue
        end
        fprintf('SE %d \n',nn)
        if exist('ff','var')&& ~isempty(ff)
            waitbar(0.2+nn/numel(seLst)*0.55,ff);
        end
        
        [ih0,iw0,it0] = ind2sub([H,W,T],se0);
        rgh = min(ih0):max(ih0); rgw = min(iw0):max(iw0);
        ihw0 = unique(sub2ind([numel(rgh),numel(rgw)],ih0-min(rgh)+1,iw0-min(rgw)+1));
        gapt = max(max(it0)-min(it0),gaptxx); rgt = max(min(it0)-gapt,1):min(max(it0)+gapt,T);
        
        dF0 = double(dF(rgh,rgw,rgt));
        seMap0 = seMap(rgh,rgw,rgt);
        [evtRecon,evtL,evtMap,dlyMap,nEvt0,rgtx,rgtSel] = burst.se2evt(...
            dF0,seMap0,nn,ihw0,rgh,rgw,rgt,it0,T,opts,1);
        
        seMap00 = seMap(rgh,rgw,rgtx);
        if ~isfield(opts,'useLongerDuration') || opts.useLongerDuration==0
            evtL(seMap00~=nn) = 0;  % avoid interfering other events
        else
            evtL(seMap00~=nn & seMap00>0) = 0;
        end
        evtL(evtL>0) = evtL(evtL>0)+nEvt;
        dLNow = datL(rgh,rgw,rgtx);
        dRNow = datR(rgh,rgw,rgtx);
        ixOld = evtRecon<dRNow;
        evtL(ixOld) = dLNow(ixOld);
        datR(rgh,rgw,rgtx) = max(datR(rgh,rgw,rgtx),evtRecon);  % combine events
        datL(rgh,rgw,rgtx) = evtL;
        riseLst = burst.addToRisingMap(riseLst,evtMap,dlyMap,nEvt,nEvt0,rgh,rgw,rgt,rgtSel);
        nEvt = nEvt + nEvt0;
        
        if(exist('f'))
           fh.nEvt.String = nEvt;
        end
        
        
        %     if nEvt>=223
        %         keyboard
        %     end
    end
    
    evtLst = label2idx(datL);
    
    % filter small events
    size2d = zeros(numel(evtLst),1);
    for i = 1:numel(evtLst)
        [ih,iw,it] = ind2sub([H,W,T],evtLst{i});
        size2d(i) = numel(unique(sub2ind([H,W],ih,iw)));
    end
    filter = size2d>opts.minSize;
    evtLst = evtLst(filter);
    riseLst = riseLst(filter);
    
    if(exist('f'))
       fh.nEvt.String = numel(evtLst);
    end
    
    % ov1 = plt.regionMapWithData(spLst,zeros(H,W),0.3); zzshow(ov1);
    % ov2 = plt.regionMapWithData(evtMap0,evtMap0*0,0.5); zzshow(ov2);
    
    if exist('ff','var') && ~isempty(ff)
        waitbar(0.8,ff);
    end
    
end



