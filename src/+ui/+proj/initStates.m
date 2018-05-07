function btSt = initStates()

btSt = [];
btSt.zoom = 0;
btSt.pan = 0;
btSt.play = 0;
btSt.sbs = 0;
btSt.leftView = 'Raw + overlay';
btSt.rightView = 'Raw';
btSt.overlayDatSel = 'None';
btSt.overlayFeatureSel = 'Index';
btSt.overlayColorSel = 'Random';
btSt.ftsCmd = [];  % features used for filtering
btSt.filterMsk = [];  % selected events by filter
btSt.regMask = [];  % selected events by region
btSt.evtMngrMsk = [];  % selected events by event manager

end