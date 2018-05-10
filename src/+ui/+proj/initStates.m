function btSt = initStates(btSt)

if ~exist('btSt','var')
    btSt = [];
end

fds = {'zoom',0; 'pan',0; 'play',0; 'sbs',0; 'leftView','Raw + overlay'; 'rightView','Raw';...
    'overlayDatSel','None'; 'overlayFeatureSel','Index'; 'overlayColorSel','Random';...
    'clickSt',[]; 'ftsCmd',[]; 'filterMsk',[]; 'regMask',[]; 'evtMngrMsk',[]; 'rmLst',[]...
    };

for ii=1:size(fds,1)
    fn0 = fds{ii,1};
    if ~isfield(btSt,fn0)
        btSt.(fn0) = fds{ii,2};
    end
end

% btSt.zoom = 0;
% btSt.pan = 0;
% btSt.play = 0;
% btSt.sbs = 0;
% btSt.leftView = 'Raw + overlay';
% btSt.rightView = 'Raw';
% btSt.overlayDatSel = 'None';
% btSt.overlayFeatureSel = 'Index';
% btSt.overlayColorSel = 'Random';
% btSt.clickSt = [];
% btSt.ftsCmd = [];  % features used for filtering
% btSt.filterMsk = [];  % selected events by filter
% btSt.regMask = [];  % selected events by region
% btSt.evtMngrMsk = [];  % selected events by event manager
% btSt.rmLst = [];  % removed list of events

end