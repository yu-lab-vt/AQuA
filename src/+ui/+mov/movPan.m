function movPan(~,~,f)
fh = guidata(f);
btSt = getappdata(f,'btSt');
col = getappdata(f,'col');
if btSt.pan==0
    btSt.pan = 1;
    fh.pan.BackgroundColor = [0.3 0.3 0.7];  % change icon color
    fh.zoom.BackgroundColor = col;  % change icon color
    h = pan;
    h.ActionPostCallback = {@ui.mov.mypostcallback,f};
    setAllowAxesPan(h,fh.curve,0);  % zoom movie only, do not zoom the dff curve
    %h.RightClickAction = 'InverseZoom';  % right click to zoom out
    h.Enable = 'on';
    h1 = zoom;  % disable zoom
    h1.Enable = 'off';
else
    btSt.pan = 0;
    fh.pan.BackgroundColor = col;
    h = pan;
    h.Enable = 'off';
end
setappdata(f,'btSt',btSt);
end