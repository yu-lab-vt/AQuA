function addPatchLineText(f,axNow,n)

bd = getappdata(f,'bd');
scl = getappdata(f,'scl');
btSt = getappdata(f,'btSt');

% % clean all patches
% types = {'quiver','line','patch','text'};
% for ii=1:numel(types)
%     h00 = findobj(axNow,'Type',types{ii});
%     if ~isempty(h00)
%         delete(h00);
%     end
% end

% user drawn boundaries (cells and landmarks, with number labels)
if bd.isKey('cell')
    bd0 = bd('cell');
    for ii=1:numel(bd0)
        xy = bd0{ii}{1};
        patch(axNow,'XData',xy(:,1),'YData',xy(:,2),'FaceColor','none','LineStyle','--','EdgeColor','b');
        text(axNow,xy(1,1)+2,xy(1,2)+2,num2str(ii),'Color','b');
    end
end
if bd.isKey('landmk')
    bd0 = bd('landmk');
    for ii=1:numel(bd0)
        xy = bd0{ii}{1};
        patch(axNow,'XData',xy(:,1),'YData',xy(:,2),'FaceColor','none','LineStyle','--','EdgeColor','y');
        text(axNow,xy(1,1)+2,xy(1,2)+2,num2str(ii),'Color','y');
    end
end

% anterior direction
if bd.isKey('diNorth')
    bd0 = bd('diNorth');
    x0 = (scl.wrg(1)+scl.wrg(2))/2;
    y0 = (scl.hrg(1)+scl.hrg(2))/2;
    dx = bd0(2,1)-bd0(1,1);
    dy = bd0(2,2)-bd0(1,2);
    l0 = sqrt(dx^2+dy^2);
    l1 = (scl.wrg(2)-scl.wrg(1))/4;
    dx = dx/l0*l1;
    dy = dy/l0*l1;
    line(axNow,[x0,x0+dx],[y0,y0+dy],'LineStyle','--');
    line(axNow,[x0,x0],[y0,y0],'Marker','o');
end

% selected events boundaries (event manager)
lst = btSt.evtMngrMsk;
opts = getappdata(f,'opts');
H = opts.sz(1);
if ~isempty(lst) && strcmp(btSt.overlayDatSel,'Events')
    ov = getappdata(f,'ov');
    ov0 = ov(btSt.overlayDatSel);
    x0 = ov0.frame{n};
    if ~isempty(x0)
        idx = x0.idx;
        fts = getappdata(f,'fts');
        bds = fts.bds;
        loc2D = fts.loc.x2D;
        for ii=1:numel(idx)
            if sum(idx(ii)==lst)>0
                % only draw when area is large enough
                nPixTot = numel(loc2D{idx(ii)});
                nPixNow = numel(x0.pix{ii});
                if nPixNow/nPixTot>0.5  % FIXME: do not make duration too long
                    xyC = bds{idx(ii)};
                    for jj=1:numel(xyC)
                        xy = xyC{jj};
                        patch(axNow,'XData',xy(:,2),'YData',H-xy(:,1)+1,'FaceColor','none','EdgeColor','g');
                        if jj==1
                            text(axNow,xy(1,2)+1,H-xy(1,1),num2str(idx(ii)),'Color',[1 0.5 0],'FontSize',18);
                        end
                    end
                end
            end
        end
    end
end

end


