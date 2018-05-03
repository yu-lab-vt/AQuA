function prepInitUI(f,fh,opts,scl,ov,stg,op)

T = opts.sz(3);

% color
col = fh.zoom.BackgroundColor;
setappdata(f,'col',col);

gap0 = [0.01 0.1];
fh.sldMin.Min = scl.min;
fh.sldMin.Max = scl.max;
fh.sldMin.SliderStep = gap0;
fh.sldMin.Value = scl.min;

fh.sldMax.Min = scl.min;
fh.sldMax.Max = scl.max;
fh.sldMax.SliderStep = gap0;
fh.sldMax.Value = scl.max;

fh.sldBri.Min = 0.1;
fh.sldBri.Max = 10;
fh.sldBri.SliderStep = gap0;
fh.sldBri.Value = scl.bri;

fh.sldMinOv.Min = 0;
fh.sldMinOv.Max = 1;
fh.sldMinOv.SliderStep = gap0;
fh.sldMinOv.Value = scl.minOv;

fh.sldMaxOv.Min = 0;
fh.sldMaxOv.Max = 1;
fh.sldMaxOv.SliderStep = gap0;
fh.sldMaxOv.Value = scl.maxOv;

fh.sldBriOv.Min = 0;
fh.sldBriOv.Max = 1;
fh.sldBriOv.SliderStep = gap0;
fh.sldBriOv.Value = scl.briOv;

if ~isempty(ov)  % fill the overlay terms
    ui.updateOvFtMenu([],[],f);
end

% show movie
fh.sldMov.Minimum = 1;
fh.sldMov.Maximum = T;
fh.sldMov.UnitIncrement = 1;
fh.sldMov.BlockIncrement = 1;
fh.sldMov.VisibleAmount = 0;
% fh.sldMov.Min = 1;
% fh.sldMov.Max = T;
% fh.sldMov.SliderStep = [1/(T-1),1/(T-1)];
fh.sldMov.Value = 1;
ui.movStep(f,1);

% fh.curTime.String = [num2str(1),'/',num2str(T)];

% detection parameters
fh.thrArScl.String = num2str(opts.thrARScl);
fh.smoXY.String = num2str(opts.smoXY);
fh.minSize.String = num2str(opts.minSize);
fh.thrTWScl.String = num2str(opts.thrTWScl);
fh.thrExtZ.String = num2str(opts.thrExtZ);
fh.cRise.String = num2str(opts.cRise);
fh.cDelay.String = num2str(opts.cDelay);
% fh.cOver.String = num2str(opts.cOver);
fh.evtGtwSmo.String = num2str(opts.gtwSmo);
fh.mergeEventDiscon.String = num2str(opts.mergeEventDiscon);

% update overlay menu
ui.updateOvFtMenu([],[],f);

% User defined features
ui.chgOv([],[],f,0);
ui.chgOv([],[],f,1);
ui.chgOv([],[],f,2);
ui.evtMngrRefresh([],[],f);

% resize GUI
fh.g.Selection = 3;
f.Position = [90 90 1400 850];
f.Resize = 'on';

% UI visibility according to steps
if stg.detect==0
    fh.pPhase.Visible = 'off';
    fh.pEvt.Visible = 'off';
    szTmp = fh.bWkfl.Heights;
    if op>0  % do not show detection panel at all
        szTmp(2) = 0;
    else
        szTmp(2) = 410;
    end
    fh.bWkfl.Heights = szTmp;
end
if stg.post==0
    fh.pFilter.Visible = 'off';
    fh.pExport.Visible = 'off';
    fh.pEvtMngr.Visible = 'off';
    fh.pSys.Visible = 'off';
else
    ui.filterInit([],[],f);
end

end

