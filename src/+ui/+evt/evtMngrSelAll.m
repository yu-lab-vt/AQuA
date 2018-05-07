function evtMngrSelAll(~,~,f)
fh = guidata(f);
tb = fh.evtTable;
dat = tb.Data;
for ii=1:size(dat,1)
    dat{ii,1} = true;
end
tb.Data = dat;
end