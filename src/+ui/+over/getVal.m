function x = getVal(fts,cmdSel,xxTrans,xxScale,xxDi,xxLmk) %#ok<INUSD>
nEvt = numel(fts.basic.area); %#ok<NASGU>
cmdSel = [cmdSel,';'];
eval(cmdSel);

if strcmp(xxTrans,'Square root')
    x(x>0) = sqrt(x(x>0));
    x(x<0) = -sqrt(-x(x<0));
end
if strcmp(xxTrans,'Log10')
    xMin = nanmin(x(x>0));
    x(x<xMin) = xMin;
    x = log10(x);
end
if strcmp(xxScale,'Size')
    xSz = fts.basic.area;
    x = x(:)./xSz(:);
end
if strcmp(xxScale,'SqrtSize')
    xSz = fts.basic.area;
    x = x(:)./sqrt(xSz(:));
end

end