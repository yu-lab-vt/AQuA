function path0 = gtw(ref,tst,s,t,smoBase,winSize)
%GETGTWPATH Use GTW to get the warping path

if winSize>1
    [ ss,ee,gInfo ] = gtw.buildGTWGraph( ref,tst,s,t,smoBase,winSize);    
    [~, labels] = aoIBFS.graphCutMex(ss,ee);
    % tic; [~, labels] = aoBK.graphCutMex(ss,ee); toc
    
    % warping functions
    path0 = gtw.label2path4Aosokin( labels, ee, ss, gInfo );
else  % no warping at all
    [nPix,nTps] = size(tst);
    path0 = cell(nPix,1);
    rg = (0:nTps)';
    p0 = [rg,rg,rg+1,rg+1];
    for ii=1:nPix
        path0{ii} = p0;
    end
end

end

