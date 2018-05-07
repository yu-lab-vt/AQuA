function mypostcallback(~,evd,f)
% adjust boundary after pan or zoom
try
    scl = getappdata(f,'scl');
    scl.wrg = evd.Axes.XLim;
    scl.hrg = evd.Axes.YLim;
    
    W = scl.W;
    H = scl.H;
    
    % do not zoom outside bound
    w1 = min(max(scl.wrg(1),1),W);
    w2 = min(max(scl.wrg(2),1),W);
    h1 = min(max(scl.hrg(1),1),H);
    h2 = min(max(scl.hrg(2),1),H);
    w = w2-w1;
    h = h2-h1;
    w = min(h,w);
    h = w;
    w2 = w1+w;
    h2 = h1+h;    
    scl.wrg = [w1,w2];
    scl.hrg = [h1,h2];

    setappdata(f,'scl',scl);
    
    % update another figure as well
    ui.mov.stepOne([],[],f);
catch
    keyboard
end