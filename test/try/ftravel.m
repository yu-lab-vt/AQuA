% traverse fields

fts = res.fts;

evtSel = false(numel(fts.loc.x2D),1);
evtSel(1:10) = true;

fts1 = assignFields(fts,evtSel);










