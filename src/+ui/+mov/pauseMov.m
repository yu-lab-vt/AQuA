function pauseMov(~,~,f)
btSt = getappdata(f,'btSt');
btSt.play = 0;
setappdata(f,'btSt',btSt);
end