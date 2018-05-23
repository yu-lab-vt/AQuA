function evtMngrRefresh(~,~,f)

fh = guidata(f);
fts = getappdata(f,'fts');
btSt = getappdata(f,'btSt');
lst = btSt.evtMngrMsk;

%{'','Index','Frame','Size','Duration','df/f','Decay tau'};
tb = fh.evtTable;
dat = cell(numel(lst),7);
if isempty(lst)
    dat = cell(0,7);
else
    for ii=1:numel(lst)
        idx00 = lst(ii);
        dat{ii,1} = false;
        dat{ii,2} = idx00;
        dat{ii,3} = fts.curve.tBegin(idx00);
        dat{ii,4} = fts.basic.area(idx00);
        dat{ii,5} = fts.curve.width55(idx00);
        dat{ii,6} = fts.curve.dffMax(idx00);
        dat{ii,7} = fts.curve.decayTau(idx00);
    end
end
tb.Data = dat;

% update detailed features
figFav = getappdata(f,'figFav');
if ~isempty(figFav) && isvalid(figFav)
    ui.evt.showDetails([],[],f);
end

end