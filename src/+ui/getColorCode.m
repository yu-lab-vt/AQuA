function col0 = getColorCode(nEvt,cType,cVal,cMap)
% getColorCode color codee each event
% nEvt: number of events
% cType: type of color code
% cVal: strength of each event for the given feature
% cMap: pre-defined color map
%
% TODO: support more than two base colors in colormap

if ~exist('cType','var') || isempty(cType)
    cType = 'Random';
end

col0 = zeros(nEvt,3);

if strcmp(cType,'Random')
    for nn=1:nEvt
        x = rand(1,3);
        while (x(1)>0.8 && x(2)>0.8 && x(3)>0.8) || sum(x)<1
            x = rand(1,3);
        end
        x = x/max(x);
        col0(nn,:) = x;
    end
end

if strcmp(cType,'Linear')
    if ~exist('cMap','var') || isempty(cMap)
        cmin = [0,1,0];
        cmax = [1,0,0];
    else
        cmin = cMap(1,:);
        cmax = cMap(end,:);
    end
    vmin = nanmin(cVal);
    vmax = nanmax(cVal);
    for nn=1:nEvt
        if ~isnan(cVal(nn))
            if vmax>vmin
                col0(nn,:) = cmin+(cVal(nn)-vmin)/(vmax-vmin)*(cmax-cmin);
            else
                col0(nn,:) = cmin;
            end
        end
    end    
end

end



