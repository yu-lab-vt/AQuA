function [p0,rgH,rgW,rgT] = pIdx2Rg(regionIndex)

p0 = regionIndex;
rgH = p0(1):p0(2);
rgW = p0(3):p0(4);
rgT = p0(5):p0(6);

end