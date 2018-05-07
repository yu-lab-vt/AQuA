function welcome(~,~,f)
fh = guidata(f);
% keyboard
fh.g.Selection = 1;
Pix_SS = get(0,'screensize');
h0 = Pix_SS(4); w0 = Pix_SS(3);
f.Position = [w0/2-150,h0/2-150,400,300];
% f.Resize = 'off';
end