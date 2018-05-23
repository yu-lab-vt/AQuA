function mypostcallback(~,evd,f)
% adjust boundary after pan or zoom
try
    scl = getappdata(f,'scl');
    scl.wrg = evd.Axes.XLim;
    scl.hrg = evd.Axes.YLim;
    
    W = scl.W;
    H = scl.H;
    
    % do not zoom outside bound
    w1 = min(max(scl.wrg(1),0.5),W+0.5);
    w2 = min(max(scl.wrg(2),0.5),W+0.5);
    h1 = min(max(scl.hrg(1),0.5),H+0.5);
    h2 = min(max(scl.hrg(2),0.5),H+0.5);
    %w = w2-w1;
    %h = h2-h1;
    %w = min(h,w);
    %h = w;
    %w2 = w1+w;
    %h2 = h1+h;    
    scl.wrg = [w1,w2];
    scl.hrg = [h1,h2];

    setappdata(f,'scl',scl);
    
    % update another figure as well
    ui.mov.stepOne([],[],f);
catch
    keyboard
end