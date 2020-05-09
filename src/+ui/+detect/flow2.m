function flow2(~,evtDat,f)
%% the function of RunAllSteps
fh = guidata(f);
opts = getappdata(f,'opts');
skipSteps = fh.skipSteps.Value==1;
opts.skipSteps = skipSteps;
setappdata(f,'opts',opts);


ui.detect.actRun([],[],f);
if(~skipSteps)
ui.detect.phaseRun([],[],f);

ui.detect.evtRun([],[],f);

ui.detect.zsRun([],[],f);
end

ui.detect.mergeRun([],[],f);

ui.detect.evtReRun([],[],f);

ui.detect.feaRun([],[],f);

% controls
fh.deOutBack.Visible = 'on';
fh.deOutRun.String = 'Extract';
fh.deOutNext.Visible = 'off';

fh.deOutTab.Selection = 7;
for i=1:7
    fh.deOutTab.TabEnables{i} = 'on';
end

end


