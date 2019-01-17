function adjMov(~,~,f,updtOv)

if ~exist('updtOv','var')
    updtOv = 1;
end

fh = guidata(f);
scl = getappdata(f,'scl');
scl.min = fh.sldMin.Value;
scl.max = fh.sldMax.Value;
scl.bri = fh.sldBri.Value;
scl.briL = fh.sldBriL.Value;
scl.briR = fh.sldBriR.Value;
scl.minOv = fh.sldMinOv.Value;
scl.maxOv = fh.sldMaxOv.Value;
scl.briOv = fh.sldBriOv.Value;
setappdata(f,'scl',scl);

% use current overlay colormap
% do not include rising time map
if updtOv
    btSt = getappdata(f,'btSt');
    ov = getappdata(f,'ov');
    ov0 = ov(btSt.overlayDatSel);
    if isfield(ov0,'colVal') && strcmp(btSt.overlayColorSel,'Random')==0
        v0 = ov0.colVal;
        gap0 = (max(v0)-min(v0))/99;
        m0 = min(v0):gap0:max(v0);
        cMap0 = ui.over.reMapCol(btSt.mapNow,m0,scl);        
        if btSt.sbs==0
            ui.over.updtColMap(fh.movColMap,m0,cMap0,1);
        end
        if btSt.sbs==1
            viewName = {'leftView','rightView'};
            axLst = {fh.movLColMap,fh.movRColMap};
            for ii=1:2
                curType = btSt.(viewName{ii});
                axNow = axLst{ii};
                if strcmp(curType,'Raw + overlay')
                    ui.over.updtColMap(axNow,m0,cMap0,1);
                else
                    ui.over.updtColMap(axNow,[],[],0);
                end
            end
        end
    else
        cMapLst = {'movColMap','movLColMap','movRColMap'};
        for ii=1:3
            ui.over.updtColMap(fh.(cMapLst{ii}),[],[],0);
        end
    end
end

ui.movStep(f);

end





