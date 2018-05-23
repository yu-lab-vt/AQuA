function back2welcome(~,~,f)
fh = guidata(f);
fh.g.Selection = 1;
f.Position = getappdata(f,'guiWelcomeSz');
end
