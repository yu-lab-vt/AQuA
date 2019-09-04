function addPatchLineText(f,axNow,n,updtAll)
    
    bd = getappdata(f,'bd');
    scl = getappdata(f,'scl');
    btSt = getappdata(f,'btSt');
    opts = getappdata(f,'opts');
    H = opts.sz(1);
    
    if ~exist('updtAll','var')
        updtAll = 1;
    end
    
    % clean all patches only when refreshing the view
    if updtAll>0
        types = {'patch','text','line'};
        for ii=1:numel(types)
            h00 = findobj(axNow,'Type',types{ii});
            %h00 = findobj(axNow,'Type',types{ii},'Tag','flex');
            if ~isempty(h00)
                delete(h00);
            end
        end
    else
        flexLst = getappdata(f,'flexLst');
        for ii=1:numel(flexLst)
            delete(flexLst{ii});
        end
        setappdata(f,'flexLst',[]);
    end   
        
    % user drawn boundaries (cells and landmarks, with number labels)
    if updtAll>0
        if bd.isKey('cell')
            bd0 = bd('cell');
            for ii=1:numel(bd0)
                xyLst = bd0{ii}{1};
                Name = 'None';
                if numel(bd0{ii})>=4
                    Name = bd0{ii}{4};
                end
                if strcmp(Name,'None')
                    Name = num2str(ii);
                end
                for jj=1:numel(xyLst)
                    xy = xyLst{jj};
                    %xy = bd0{ii}{1};
                    patch(axNow,'XData',xy(:,2),'YData',H-xy(:,1)+1,...
                        'FaceColor','none','LineStyle','-','EdgeColor',[0.5 0.5 0.8],'Tag','fix');
                    if jj==1
                        text(axNow,xy(1,2)+2,H-xy(1,1)+2,Name,'Color',[0.7 0.7 0.9],'Tag','fix','FontSize',14);
                    end
                end                
            end
        end
        
        if bd.isKey('landmk')
            bd0 = bd('landmk');
            for ii=1:numel(bd0)
                xyLst = bd0{ii}{1};
                Name = 'None';
                if numel(bd0{ii})>=4
                    Name = bd0{ii}{4};
                end
                if strcmp(Name,'None')
                    Name = num2str(ii);
                end
                for jj=1:numel(xyLst)
                    xy = xyLst{jj};
                    %xy = bd0{ii}{1};
                    patch(axNow,'XData',xy(:,2),'YData',H-xy(:,1)+1,...
                        'FaceColor','none','LineStyle','-','EdgeColor',[0.4 0.4 0],'Tag','fix');
                    if jj==1
                        text(axNow,xy(1,2)+2,H-xy(1,1)+2,Name,'Color','y','Tag','fix');
                    end
                end                
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
    
    ui.over.addBd(f,axNow,btSt.evtMngrMsk,[1 0.85 0],n);
    ui.over.addBd(f,axNow,btSt.rmLst,[1 0.25 0.25],n);
    
end






