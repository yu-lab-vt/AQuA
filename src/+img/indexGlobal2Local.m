function idxOut = indexGlobal2Local( idxIn,szIn,rg )
%INDEXGLOBAL2LOCAL index in large box to a small box

[ih,iw,it] = ind2sub(szIn,idxIn);
ih = ih - rg(1) + 1;
iw = iw - rg(3) + 1;
it = it - rg(5) + 1;
idxOut = sub2ind([rg(2)-rg(1)+1,rg(4)-rg(3)+1,rg(6)-rg(5)+1],ih,iw,it);

end

