function getInputFile(~,~,f)
fh = guidata(f);
% cfgFile = 'uicfg.mat';
p0 = '.';
% if exist(cfgFile,'file')
%     xx = load(cfgFile);
%     if isfield(xx,'cfg0') && isfield(xx.cfg0,'file')
%         p0 = xx.cfg0.file;
%     end
% end
[FileName,PathName] = uigetfile({'*.tif;*.mat','*.tiff'},'Choose movie',p0);
if ~isempty(FileName) && ~isnumeric(FileName)
    fh.fIn.String = [PathName,FileName];
end
end
