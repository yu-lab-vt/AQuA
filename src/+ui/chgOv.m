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
        xxx = 'on';
    else        
        xxx = 'off';
    end
    fh.overlayFeature.Enable = xxx;
    fh.overlayColor.Enable = xxx;
    fh.overlayTrans.Enable = xxx;
    fh.overlayScale.Enable = xxx;
    fh.overlayPropDi.Enable = xxx;
    fh.overlayLmk.Enable = xxx;
    fh.sldMinOv.Enable = xxx;
    fh.sldMaxOv.Enable = xxx;
    fh.sldBriOv.Enable = xxx;
    fh.updtFeature1.Enable = xxx;
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
    if strcmp(ovFea,'Index')
        ovCol = 'Random';
        fh.overlayColor.Value = 1;
    else
        if strcmp(ovCol,'Random')
            ovCol = 'GreenRed';
            fh.overlayColor.Value = 2;
        end
    end    
    
    btSt.overlayFeatureSel = ovFea;
    btSt.overlayColorSel = ovCol;
        
    xxTrans = fh.overlayTrans.String{fh.overlayTrans.Value};  % transform
    xxScale = fh.overlayScale.String{fh.overlayScale.Value};  % scale
    xxDi = fh.overlayPropDi.Value;  % direction
    xxLmk = str2double(fh.overlayLmk.String);  % landmark
        
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
        cVal = getVal(fts,cmdSel,xxTrans,xxScale,xxDi,xxLmk);
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
    
    fh.sldMinOv.Min = nanmin(cVal);
    fh.sldMinOv.Max = nanmax(cVal);
    fh.sldMinOv.Value = nanmin(cVal);
    fh.sldMaxOv.Min = nanmin(cVal);
    fh.sldMaxOv.Max = nanmax(cVal);
    fh.sldMaxOv.Value = nanmax(cVal);
    fh.sldMinOv.Enable = 'on';
    fh.sldMaxOv.Enable = 'on';
    %fh.txtMinOv.String = ['Min:',num2str(nanmin(cVal))];
    %fh.txtMaxOv.String = ['Max:',num2str(nanmax(cVal))];
    fh.txtMinOv.String = ['Min:',num2str(scl.minOv)];
    fh.txtMaxOv.String = ['Max:',num2str(scl.maxOv)];
end

setappdata(f,'btSt',btSt);

% show movie with overlay
ui.movStep(f);
end

function x=getVal(fts,cmdSel,xxTrans,xxScale,xxDi,xxLmk) %#ok<INUSD>
nEvt = numel(fts.basic.area); %#ok<NASGU>
cmdSel = [cmdSel,';'];
eval(cmdSel);

if strcmp(xxTrans,'Square root')
    x(x>0) = sqrt(x(x>0));
    x(x<0) = -sqrt(-x(x<0));
end
if strcmp(xxTrans,'Log10')
    xMin = nanmin(x(x>0));
    x(x<xMin) = xMin;
    x = log10(x);
end
if strcmp(xxScale,'Size')
    xSz = fts.basic.area;
    x = x./xSz;
end

end





