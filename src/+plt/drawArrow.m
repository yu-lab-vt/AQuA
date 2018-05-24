function hOut = drawArrow(x,y,varargin)
% Input arguments are the same as for annotation('arrow',...) but the
% position is given in the axes coordinate system

pos = [x(1) y(1) x(2)-x(1) y(2)-y(1)]; 
hOut = annotation('arrow',varargin{1:end});

set(hOut,'parent',gca); 
set(hOut,'position',pos);

end