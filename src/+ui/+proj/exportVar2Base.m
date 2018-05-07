function exportVar2Base(~,~,f)
res = ui.proj.saveExp([],[],f,[],[],1);
assignin('base','res_dbg',res);
end