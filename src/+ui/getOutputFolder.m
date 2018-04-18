function getOutputFolder(~,~,f)
opts = getappdata(f,'opts');
[file0,path0] = uiputfile('*.mat','Save experiment',opts.fileName);
if ~isnumeric(file0)
    ui.saveExp([],[],f,file0,path0);
end
end