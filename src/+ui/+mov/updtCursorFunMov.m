function updtCursorFunMov(~,~,f,op,lbl)
% btSt = getappdata(f,'btSt');
% btSt.rmLbl = lbl;
% setappdata(f,'btSt');
fh = guidata(f);
% fh.mov.ButtonDownFcn = {@ui.getCursorPosMov,f,op,lbl};
fh.im.ButtonDownFcn = {@ui.mov.movClick,f,op,lbl};
guidata(f,fh);

end