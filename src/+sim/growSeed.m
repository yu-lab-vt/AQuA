function [regMap,delayMap,pixLst] = growSeed(seedIdx,initTime,sucRt,sucRtBase,regMask,p)

    H = p.sz(1);
    W = p.sz(2);
    nEvt = numel(seedIdx);
    
    regMap = zeros(H,W);
    regMap(seedIdx) = 1:nEvt;
    delayMap = nan(H,W);
    delayMap(seedIdx) = initTime;
    pixLst = num2cell(seedIdx);
    
    dh = [0 -1 1 0];
    dw = [-1 0 0 1];
    for tt=1:p.nStpGrow
        if mod(tt,10)==0
            nNow = sum(regMap(:)>0);
            rt = nNow/sum(p.fg(:));           
            %fprintf('%d - %f\n',tt,rt)
            %RGB2 = label2rgb(regMap,'jet','w','shuffle'); zzshow(RGB2); keyboard; close
            if rt>p.szRt
                break
            end
        end
        for nn=1:nEvt
            if tt<=initTime(nn)
                continue
            end
            suc0 = sucRt(nn);
            pix0 = pixLst{nn};
            tGap = max(delayMap(pix0))-initTime(nn);
            tScl = max(tGap^p.speedUpProp/5,1);
            [ih0,iw0] = ind2sub([H,W],pix0);
            for ii=randperm(numel(dh))
                ih0a = min(max(ih0+dh(ii),1),H);
                iw0a = min(max(iw0+dw(ii),1),W);
                pix0a = sub2ind([H,W],ih0a,iw0a);
                pix0a = pix0a(regMap(pix0a)==0);
                if ~isempty(regMask)
                    pix0a = pix0a(regMask(pix0a)==nn);
                end
                %pix0a = pix0a(fg(pix0a)>0);
                isSuc = rand(size(pix0a))>1-sucRtBase(pix0a)*suc0*tScl;
                pix0a = pix0a(isSuc);
                pix0 = union(pix0,pix0a);
                regMap(pix0a) = nn;
                delayMap(pix0a) = tt;
            end
            pixLst{nn} = pix0;
        end
    end    
    
    fprintf('%d - %f\n',tt,rt)
    
end

