function updtColMap(axNow,m0,cMap0,op)

h00 = findobj(axNow,'Type','image');
delete(h00);
axNow.XTick=[];
axNow.XTickLabel=[];

if op==0
    c0 = zeros(1,100);
    image(axNow,'CData',c0);
    axNow.DataAspectRatio = [1 1 1];
    colormap(axNow,[1 1 1])
end

if op==1
    image(axNow,'CData',m0,'CDataMapping','scaled');
    W = axNow.Position(3);
    if W>600
        xxtik = [1,20,40,60,80,100];
    elseif W>300
        xxtik = [1,50,100];
    else
        xxtik = [1,100];
    end    
    %xxtik = axNow.XTick;
    xxlbl = cellstr(num2str(m0(xxtik)'));
    axNow.XTick = xxtik;
    axNow.XTickLabel = xxlbl;    
    colormap(axNow,cMap0)
end

axNow.XLim = [1 100];
axNow.YTick = [];
axNow.DataAspectRatio = [1 1 1];

end