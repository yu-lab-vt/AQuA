function addPatchLineText(f,axNow,n,updtAll)
    
    bd = getappdata(f,'bd');
    scl = getappdata(f,'scl');
    btSt = getappdata(f,'btSt');
    
    if ~exist('updtAll','var')
        updtAll = 1;
    end
    
    % clean all patches
    types = {'patch','text','line'};
    for ii=1:numel(types)
        if updtAll>0
            h00 = findobj(axNow,'Type',types{ii});
        else
            h00 = findobj(axNow,'Type',types{ii},'Tag','flex');
        end
        if ~isempty(h00)
            delete(h00);
        end
    end
    
    % user drawn boundaries (cells and landmarks, with number labels)
    if updtAll>0
        if bd.isKey('cell')
            bd0 = bd('cell');
            for ii=1:numel(bd0)
                xy = bd0{ii}{1};
                patch(axNow,'XData',xy(:,1),'YData',xy(:,2),...
                    'FaceColor','none','LineStyle','-','EdgeColor',[0.2 0.2 0.5],'Tag','fix');
                text(axNow,xy(1,1)+2,xy(1,2)+2,num2str(ii),'Color','b','Tag','fix');
            end
        end
        
        if bd.isKey('landmk')
            bd0 = bd('landmk');
            for ii=1:numel(bd0)
                xy = bd0{ii}{1};
                patch(axNow,'XData',xy(:,1),'YData',xy(:,2),...
                    'FaceColor','none','LineStyle','-','EdgeColor',[0.4 0.4 0],'Tag','fix');
                text(axNow,xy(1,1)+2,xy(1,2)+2,num2str(ii),'Color','y','Tag','fix');
            end
        end
    end
    
    % anterior direction
    if updtAll>0
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
            line(axNow,[x0,x0+dx],[y0,y0+dy],'LineStyle','--','Tag','fix');
            line(axNow,[x0,x0],[y0,y0],'Marker','o','Tag','fix');
        end
    end
    
    ui.over.addBd(f,axNow,btSt.evtMngrMsk,[0 0.5 0],n);
    ui.over.addBd(f,axNow,btSt.rmLst,[0.5 0 0],n);
    
end






