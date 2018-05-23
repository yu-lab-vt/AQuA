function exportVar2Base(~, ~, f)
    res = ui.proj.saveExp([], [], f, [], [], 1);
    if exist('res','var')
        assignin('base', 'res_dbg', res);
    end
end 
