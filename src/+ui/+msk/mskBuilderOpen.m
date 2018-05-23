function mskBuilderOpen(~,~,f)
    fh = guidata(f);
    
    fgOK = 0;
    bgOK = 0;
    bd = getappdata(f,'bd');
    if bd.isKey('maskLst')
        bdMsk = bd('maskLst');
        for ii=1:numel(bdMsk)
            rr = bdMsk{ii};
            if strcmp(rr.type,'foreground')
                fgOK = 1;
            end
            if strcmp(rr.type,'foreground')
                bgOK = 1;
            end
        end
    end
    
    if fgOK==0
        ui.msk.readMsk([],[],f,'self','foreground',0);
    end
    if bgOK==0
        ui.msk.readMsk([],[],f,'self','background',0);
    end
    
    fh.g.Selection = 4;
end