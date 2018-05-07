function aqua_gui(res)
%AQUA_GUI GUI for AQUA

startup;

f = figure('Name','AQUA','MenuBar','none','Toolbar','none',...
    'NumberTitle','off','Visible','off');
Pix_SS = get(0,'screensize');
h0 = Pix_SS(4); w0 = Pix_SS(3);
f.Position = [w0/2-150,h0/2-150,400,300];

ui.com.addCon(f,1);
if exist('res','var')
    ui.proj.prep([],[],f,2,res);
end
f.Visible = 'on';

end




















