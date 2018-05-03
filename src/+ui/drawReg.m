function drawReg(~,~,f,op,lbl)
% updtFeature update network features after user draw regions

fh = guidata(f);
bd = getappdata(f,'bd');

if bd.isKey(lbl)
    bd0 = bd(lbl);
else
    bd0 = [];
end

ax = fh.mov;

if strcmp(op,'add')
    tmp = [];
    hh = impoly(ax);
    if ~isempty(hh)
        tmp{1} = hh.getPosition;
        tmp{2} = hh.createMask;
        bd0{end+1} = tmp;
        delete(hh)
    end
end

% if strcmp(op,'rm')    
%     % get mouse click position
%     ax.ButtonDownFcn = {@ui.movClick,f};
% end

bd(lbl) = bd0;
setappdata(f,'bd',bd);
f.Pointer = 'arrow';
ui.movStep(f);

end







