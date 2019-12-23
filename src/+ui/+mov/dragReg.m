function dragReg(~,~,f,op,lbl)
    % updtFeature update network features after user draw regions
    
    fh = guidata(f);
    bd = getappdata(f,'bd');
    btSt = getappdata(f,'btSt');
    col = getappdata(f,'col');
    
    if bd.isKey(lbl)
        bd0 = bd(lbl);
    else
        bd0 = [];
    end
    
    ax = fh.mov;
    if btSt.sbs==0
        ax = fh.mov;
    end
    if btSt.sbs==1
        ax = fh.movL;
    end
    
    opts = getappdata(f,'opts');
    H = opts.sz(1);
    W = opts.sz(2);
    
    if strcmp(op,'drag')
        hh = imline(ax);
        if ~isempty(hh)
            points = hh.getPosition;
            xshift = round(points(2,1)-points(1,1));
            yshift = round(points(2,2)-points(1,2));
            iw0 = max(min(round(points(1,1)),W),1);
            ih0 = max(min(H-round(points(1,2))+1,H),1);
            ihw0= sub2ind([H,W],ih0,iw0);
            for ii = 1:numel(bd0)
                tmp = bd0{ii};
                pix = tmp{2};
                if ismember(ihw0,pix)
                    [ih,iw] = ind2sub([H,W],pix);
                    ih = max(1,min(H,ih-yshift));
                    iw = max(1,min(W,iw+xshift));
                    pix = unique(sub2ind([H,W],ih,iw));
                    msk = false(H,W);
                    msk(pix) = true;
                    tmp{1} = bwboundaries(msk);
                    tmp{2} = pix;
                    bd0{ii} = tmp;
                end
            end
            fh.DragLm.BackgroundColor = col;
            fh.DragCell.BackgroundColor = col;
            fh.DragLm.ForegroundColor = [0 0 0];
            fh.DragCell.ForegroundColor = [0 0 0];
            delete(hh)
        end
    end
    
    bd(lbl) = bd0;
%     setappdata(f,'bd',bd);
%     f.Pointer = 'arrow';
    ui.movStep(f,[],[],1);
    
end