function flow2(~,evtDat,f)
%% the function of RunAllSteps
fh = guidata(f);



ui.detect.actRun([],[],f);

ui.detect.phaseRun([],[],f);

ui.detect.evtRun([],[],f);

ui.detect.zsRun([],[],f);

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


