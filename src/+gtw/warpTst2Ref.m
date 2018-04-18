function datWarp = warpTst2Ref(pathCell,dat,validMap,useVec)
%WARPREF2TST warp the reference curve to each pixel
%   pathCell is H by W cell array for warping functions
%   If useVec, dat is tst curves, otherwise, dat is movie

if ~exist('useVec','var')
    useVec = 0;
end

if useVec==0
    [H,W,T] = size(dat);
    %H = sz(1); W = sz(2); T = sz(3);
    datWarp = zeros(H,W,T);
    for hh=1:H
        for ww=1:W
            if validMap(hh,ww)>0
                tst0 = dat(hh,ww,:);
                x0 = zeros(1,T);  % warped curve
                c0 = zeros(1,T);  % count the occurrence
                p0 = pathCell{hh,ww}(:,1:2);
                idxValid = p0(:,1)>=1 & p0(:,1)<=T & p0(:,2)>=1 & p0(:,2)<=T;
                p0 = p0(idxValid,:);
                for tt=1:length(p0)
                    p_ref = p0(tt,1);
                    p_tst = p0(tt,2);
                    x0(p_ref) = x0(p_ref) + tst0(p_tst);
                    c0(p_ref) = c0(p_ref) + 1;
                end
                c0(c0==0) = 1;
                datWarp(hh,ww,:) = x0./c0;
            end
        end
    end
end

if useVec==1
    T = size(dat,2);
    datWarp = zeros(size(dat));
    ix = find(validMap>0);
    for ii=1:numel(ix)
        tst0 = dat(ii,:);
        x0 = zeros(1,T);  % warped curve
        c0 = zeros(1,T);  % count the occurrence
        p0 = pathCell{ix(ii)}(:,1:2);
        idxValid = p0(:,1)>=1 & p0(:,1)<=T & p0(:,2)>=1 & p0(:,2)<=T;
        p0 = p0(idxValid,:);
        for tt=1:length(p0)
            p_ref = p0(tt,1);
            p_tst = p0(tt,2);
            x0(p_ref) = x0(p_ref) + tst0(p_tst);
            c0(p_ref) = c0(p_ref) + 1;
        end
        c0(c0==0) = 1;
        datWarp(ii,:) = x0./c0;
    end    
end

end

