function evtMap = seperateEvents(seMap,bd)
    sz = size(seMap);
    evtMap = zeros(size(seMap));    
    
    if exist('bd') && ~isempty(bd) && bd.isKey('cell')
        bd0 = bd('cell');
        bdMap = zeros(sz(1)*sz(2),1);
        for ii=1:numel(bd0)
            p0 = bd0{ii}{2};
            bdMap(p0) = ii;     
        end
        bdMap = reshape(bdMap,sz(1:2));
    else
        bdMap = ones(sz(1:2));
    end
    
    bd0 = label2idx(bdMap);
    seLst = label2idx(seMap);
    cnt = 1;
    
    
    
    for i = 1:numel(seLst)
        pixSet = seLst{i};
        [ih,iw,it] = ind2sub(sz,pixSet);
        ihw = sub2ind(sz(1:2),ih,iw);
        bdcell = unique(bdMap(ihw));
        bdcell = setdiff(bdcell,0);
        if(numel(bdcell)==0)
            continue;
        else
            if(numel(bdcell)==1)
                evtMap(pixSet) = cnt;
                cnt = cnt + 1;
            else
                for k = 1:numel(bdcell)
                    bd00 = bd0{bdcell(k)};
                   idx = ismember(ihw,bd00);
                   evtMap(pixSet(idx)) = cnt;
                   cnt = cnt + 1;
                end
            end
        end
    
    end




end