function movClick(~,evtDat,f,op,lbl)
% get cursor location and run operation specified by op when click movie
%
% Note the difference between image cooridate and matrix coordinate
% For 512 by 512 image, (1,1) in matrix is (1,512) in movie
% Image object begin with (0.5,0.5) to (512.5,512.5)

fh = guidata(f);
opts = getappdata(f,'opts');
sz = opts.sz;

xy = evtDat.IntersectionPoint;
x = max(round(xy(1)),1);
y = max(round(xy(2)),1);

% remove drawn regions
if strcmp(lbl,'cell') || strcmp(lbl,'landmk')
    
    bd = getappdata(f,'bd');
    xrg = max(x-1,1):min(x+1,sz(2));
    yrg = max(y-1,1):min(y+1,sz(1));
    if(strcmp(op,'rm')) %remove
        if bd.isKey(lbl)
            bd0 = bd(lbl);
            for ii=1:numel(bd0)
                map00 = zeros(sz(1),sz(2));
                x00 = bd0{ii}{2};
                map00(x00) = 1;
                map00 = flipud(map00);
                %map00 = bd0{ii}{2};
                %map00 = poly2mask(x00(:,1),x00(:,2),sz(1),sz(2));
                v00 = map00(yrg,xrg);
                if sum(v00(:))>0
                    bd0{ii} = [];
                end
            end
            idxSel = cellfun(@isempty,bd0);
            bd0 = bd0(~idxSel);
            bd(lbl) = bd0;
        end
        setappdata(f,'bd',bd);
    else
       % name
       if bd.isKey(lbl)
            bd0 = bd(lbl);
            for ii=1:numel(bd0)
                map00 = zeros(sz(1),sz(2));
                x00 = bd0{ii}{2};
                map00(x00) = 1;
                map00 = flipud(map00);
                v00 = map00(yrg,xrg);
                if sum(v00(:))>0
                    % dialog
                    if numel(bd0{ii})>=4
                        curName = {bd0{ii}{4}};
                    else
                        curName = {num2str(ii)};
                    end
                    answer = inputdlg('New Name','Name',1,curName);
                    if(~isempty(answer))
                        bd0{ii}{4} = answer{1};
                    end
                end
            end
            idxSel = cellfun(@isempty,bd0);
            bd0 = bd0(~idxSel);
            bd(lbl) = bd0;
        end
        setappdata(f,'bd',bd);
    end
end

% show curve, add to favourite or delete from favourite
if strcmp(lbl,'viewFav')
    ov = getappdata(f,'ov');
    if ov.isKey('Events')
        ov0 = ov('Events');
        n = fh.sldMov.Value;
        tmp = zeros(sz(1),sz(2));
        ov00 = ov0.frame{n};
        if ~isempty(ov00)
            for ii=1:numel(ov00.idx)
                idx00 = ov00.idx(ii);
                pix00 = ov00.pix{ii};
                tmp(pix00) = idx00;
            end
        end
        y0 = min(max(sz(1)-y+1,1),sz(1));
        x0 = min(max(x,1),sz(2));
        evtIdx = tmp(y0,x0);      
        fprintf('x %f y %f evt %d\n',xy(1),xy(2),evtIdx);
        
        if evtIdx>0
            % add to or remove from event list
            btSt = getappdata(f,'btSt');
            lst = btSt.evtMngrMsk;
            if isempty(lst) || sum(lst==evtIdx)==0
                lst = union(lst,evtIdx);            
                ui.evt.curveRefresh([],[],f,evtIdx);  % draw curve
            else
                lst = lst(lst~=evtIdx);                
            end 
            btSt.evtMngrMsk = lst;
            setappdata(f,'btSt',btSt);
            
            % refresh event manager
            ui.evt.evtMngrRefresh([],[],f);                       
        end
    end    
end

% remove and restore
if strcmp(lbl,'delRes')
    ov = getappdata(f,'ov');
    if ov.isKey('Events')
        ov0 = ov('Events');
        n = fh.sldMov.Value;
        tmp = zeros(sz(1),sz(2));
        ov00 = ov0.frame{n};
        if ~isempty(ov00)
            for ii=1:numel(ov00.idx)
                idx00 = ov00.idx(ii);
                pix00 = ov00.pix{ii};
                tmp(pix00) = idx00;
            end
        end
        y0 = min(max(sz(1)-y+1,1),sz(1));
        x0 = min(max(x,1),sz(2));
        evtIdx = tmp(y0,x0);      
        fprintf('x %f y %f evt %d\n',xy(1),xy(2),evtIdx);
        
        if evtIdx>0
            % add to or remove from event list
            btSt = getappdata(f,'btSt');
            lst = btSt.rmLst;
            if isempty(lst) || sum(lst==evtIdx)==0
                lst = union(lst,evtIdx);            
                ui.evt.curveRefresh([],[],f,evtIdx);  % draw curve
            else
                lst = lst(lst~=evtIdx);                
            end
            btSt.rmLst = lst;
            setappdata(f,'btSt',btSt);       
            ui.over.updtEvtOvShowLst([],[],f);
        end
    end    
end

% refresh movie
ui.movStep(f,[],[],1);

end


