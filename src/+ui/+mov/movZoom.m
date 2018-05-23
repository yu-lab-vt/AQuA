% single frame navigation
% Each figure has only one zoom mode object?
function movZoom(~,~,f)
fh = guidata(f);
btSt = getappdata(f,'btSt');
col = getappdata(f,'col');
if btSt.zoom==0
    btSt.zoom = 1;
    fh.zoom.BackgroundColor = [0.3 0.3 0.7];  % change icon color
    fh.pan.BackgroundColor = col;  % change icon color
    h = zoom;
    h.ActionPostCallback = {@ui.mov.mypostcallback,f};
    %setAllowAxesZoom(h,fh.curve,0);  % zoom movie only, do not zoom the dff curve
    h.RightClickAction = 'InverseZoom';  % right click to zoom out
    h.Enable = 'on';
    h1 = pan;  % disable pan
    h1.Enable = 'off';
else
    btSt.zoom = 0;
    fh.zoom.BackgroundColor = col;
    h = zoom;
    h.Enable = 'off';
end
setappdata(f,'btSt',btSt);
end