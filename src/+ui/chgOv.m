function chgOv(~,~,f,op)
% overlay related functions

fh = guidata(f);

% enable or disable overlay features
if op==0
    tb = readtable('./cfg/userFeatures.csv','Delimiter',',');
    setappdata(f,'userFeatures',tb);
    fh.overlayFeature.String = tb.Name;
    fprintf('Reading done.\n');
    return
end

% update overlay features
if op==1
    ovName = fh.overlayDat.String{fh.overlayDat.Value};
    if strcmp(ovName,'Events')
        fh.overlayFeature.Enable = 'on';
        fh.overlayColor.Enable = 'on';
    else
        fh.overlayFeature.Enable = 'off';
        fh.overlayColor.Enable = 'off';
        %fh.overlayColor.Value = 1;  % !!
        fh.sldMinOv.Enable = 'off';
        fh.sldMaxOv.Enable = 'off';
    end
    return
end

% calcuate overlay
idx = fh.overlayDat.Value;
ovSel = fh.overlayDat.String{idx};

btSt = getappdata(f,'btSt');
btSt.overlayDatSel = ovSel;
btSt.overlayColorSel = 'Random';

% update color code for events
if strcmp(ovSel,'Events')    
    ovFea = fh.overlayFeature.String{fh.overlayFeature.Value};
    ovCol = fh.overlayColor.String{fh.overlayColor.Value};
    
    btSt.overlayFeatureSel = ovFea;
    btSt.overlayColorSel = ovCol;
    
    fts = getappdata(f,'fts');
    tb = getappdata(f,'userFeatures');
    xSel = cellfun(@(x) strcmp(x,ovFea), tb.Name);
    cmdSel = tb.Script{xSel};
    if isfield(fts,'locAbs')
        nEvt = numel(fts.locAbs);
    else
        nEvt = numel(fts.basic.area);
    end
    
    % change overlay value according to user input
    %cmdSel = ['cVal=',cmdSel,';'];
    try
        cVal = getVal(fts,cmdSel,nEvt);
    catch
        msgbox('Invalid script');
        return
    end
    
    % update overlay color
    col0 = ui.getColorCode(nEvt,ovCol,cVal);
    ov = getappdata(f,'ov');
    ov0 = ov('Events');
    ov0.col = col0;
    ov0.colVal = cVal;
    ov('Events') = ov0;
    setappdata(f,'ov',ov);
    
    % update min, max and brightness slider
    scl = getappdata(f,'scl');
    scl.minOv = min(cVal);
    scl.maxOv = max(cVal);
    setappdata(f,'scl',scl);
    
    fh.sldMinOv.Min = min(cVal);
    fh.sldMinOv.Max = max(cVal);
    fh.sldMinOv.Value = min(cVal);
    fh.sldMaxOv.Min = min(cVal);
    fh.sldMaxOv.Max = max(cVal);
    fh.sldMaxOv.Value = max(cVal);
    fh.sldMinOv.Enable = 'on';
    fh.sldMaxOv.Enable = 'on';
end

setappdata(f,'btSt',btSt);

% show movie with overlay
ui.movStep(f);
end

function x=getVal(fts,cmdSel,nEvt) %#ok<STOUT,INUSD,INUSL>
cmdSel = [cmdSel,';'];
eval(cmdSel);
end





