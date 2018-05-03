function exportVar2Base(~,~,f)
res = ui.saveExp([],[],f,[],[],1);
assignin('base','res_dbg',res);
end