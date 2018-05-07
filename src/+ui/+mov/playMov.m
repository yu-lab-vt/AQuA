function playMov(~,~,f)
fh = guidata(f);
fh.play.Enable = 'off';
try
    pauseTime = 1/str2double(fh.playbackRate.String);
catch
    pauseTime = 0.2;
end
btSt = getappdata(f,'btSt');
btSt.play = 1;
setappdata(f,'btSt',btSt);
n0 = round(fh.sldMov.Value);
scl = getappdata(f,'scl');
for nn=n0:scl.T
    btSt = getappdata(f,'btSt');
    playx = btSt.play;
    if playx==0  % interrupted by pauseMov
        break
    end
    ui.movStep(f,nn);
    fh.sldMov.Value = nn;
    pause(pauseTime);
end
fh.play.Enable = 'on';
end