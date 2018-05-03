function datx = movStep(f,n,ovOnly)

if ~exist('n','var') || isempty(n)
    fh = guidata(f);
    n = fh.sldMov.Value;
end

dat = getappdata(f,'dat');
scl = getappdata(f,'scl');

% re-scale movie
dat0 = dat(:,:,n);
if scl.map==1
    dat0 = dat0.^2;
end
dat0 = (dat0-scl.min)/max(scl.max-scl.min,0.01)*scl.bri;
datx = cat(3,dat0,dat0,dat0);

%% overlay
st = getappdata(f,'btSt');
sclOv = scl.briOv;
if ~strcmp(st.overlayDatSel,'None')
    ov = getappdata(f,'ov');
    ov0 = ov(st.overlayDatSel);
    x0 = ov0.frame{n};
    c0 = ov0.col;
    
    % remap color
    if isfield(ov0,'colVal') && strcmp(st.overlayColorSel,'Random')==0
        v0 = ov0.colVal;
        [~,ix] = min(v0); cmin = c0(ix,:);
        [~,ix] = max(v0); cmax = c0(ix,:);
        for ii=1:numel(v0)
            if v0(ii)<scl.minOv
                c0(ii,:) = cmin;
                continue
            end
            if v0(ii)>scl.maxOv
                c0(ii,:) = cmax;
                continue
            end
            c0(ii,:) = cmin+(v0(ii)-scl.minOv)/(scl.maxOv-scl.minOv)*(cmax-cmin);
        end
    end
    
    % show movie with overlay
    if ~isempty(x0)
        rPlane = dat0*0;
        gPlane = rPlane;
        bPlane = rPlane;
        reCon = dat0*0;
        for ii=1:numel(x0.idx)
            idx0 = x0.idx(ii);
            if ov0.sel(idx0)>0
                pix0 = x0.pix{ii};
                val0 = x0.val{ii};
                col0 = c0(idx0,:);
                rPlane(pix0) = col0(1);
                gPlane(pix0) = col0(2);
                bPlane(pix0) = col0(3);
                reCon(pix0) = val0;
            end
        end
        datx(:,:,1) = rPlane*sclOv.*reCon + datx(:,:,1);
        datx(:,:,2) = gPlane*sclOv.*reCon + datx(:,:,2);
        datx(:,:,3) = bPlane*sclOv.*reCon + datx(:,:,3);
    end
end

% display
fh = guidata(f);
fh.im.CData = flipud(datx);
% fh.im.CDataMapping = 'scaled';
fh.mov.XLim = scl.wrg;
fh.mov.YLim = scl.hrg;

if exist('ovOnly','var')
    if ovOnly>0
        return
    end
end

%% patches
% clean all patches
h00 = findobj(gca,'Type','patch');
if ~isempty(h00)
    delete(h00);
end
h00 = findobj(gca,'Type','text');
if ~isempty(h00)
    delete(h00);
end

% user drawn boundaries (cells and landmarks, with number labels)
bd = getappdata(f,'bd');
if bd.isKey('cell')
    bd0 = bd('cell');
    for ii=1:numel(bd0)
        xy = bd0{ii}{1};
        patch(fh.mov,'XData',xy(:,1),'YData',xy(:,2),'FaceColor','none','LineStyle','--','EdgeColor','b');
        text(fh.mov,xy(1,1)+2,xy(1,2)+2,num2str(ii),'Color','b');
    end
end
if bd.isKey('landmk')
    bd0 = bd('landmk');
    for ii=1:numel(bd0)
        xy = bd0{ii}{1};
        patch(fh.mov,'XData',xy(:,1),'YData',xy(:,2),'FaceColor','none','LineStyle','--','EdgeColor','y');
        text(fh.mov,xy(1,1)+2,xy(1,2)+2,num2str(ii),'Color','y');
    end
end

% selected events boundaries (event manager)
btSt = getappdata(f,'btSt');
lst = btSt.evtMngrMsk;
H = size(dat,2);
if ~isempty(lst) && strcmp(st.overlayDatSel,'Events')
    ov = getappdata(f,'ov');
    ov0 = ov(st.overlayDatSel);
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
                if nPixNow/nPixTot>0.5  % !!
                    xyC = bds{idx(ii)};
                    for jj=1:numel(xyC)
                        xy = xyC{jj};
                        patch(fh.mov,'XData',xy(:,2),'YData',H-xy(:,1)+1,'FaceColor','none','EdgeColor','g');
                        if jj==1
                            text(fh.mov,xy(1,2)+1,H-xy(1,1),num2str(idx(ii)),'Color',[1 0.5 0],'FontSize',18);
                        end
                    end
                end
            end
        end
    end
end

%% frame and time
opts = getappdata(f,'opts');
n1 = n; n2 = size(dat,3);
t1 = n1*opts.frameRate; t2 = n2*opts.frameRate;
n_str = [num2str(n1),'/',num2str(n2),' Frame'];
t_str = [num2str(t1),'/',num2str(t2),' Second'];
fh.curTime.String = [n_str,'  ',t_str];

f.Pointer = 'arrow';

end



