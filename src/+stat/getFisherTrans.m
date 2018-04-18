function Xf = getFisherTrans( X, L )
%GETFISHERTRANS Fisher transform on X

if L<=3
    L = 4;
%     fprintf('Too short signal.');
end

Xf = 0.5*log((1+X)./(1-X))*sqrt(L-3);

end

