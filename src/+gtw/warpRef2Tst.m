function [datWarp,tVecOut,validMapx] = warpRef2Tst(pathCell,ref,validMap,sz,tVecIn,outType)
%WARPREF2TST warp the reference curve to each pixel
%   Some other features:
%   Generate the new position of given list of time points
%   Input path in 2D cell array, but allow two output types
%   Allow missing values in reference curve

if ~exist('outType','var')
    outType = 0;  % 0: HxWxT. 1: NxT
end
if ~exist('tVecIn','var')
    tVecIn = [];  % 0: HxWxT. 1: NxT
end

if numel(sz)==3
    H = sz(1); W = sz(2); T = sz(3);
else
    [H,W] = size(validMap);
    T = sz;
end

nPix = sum(validMap(:)>0);
validMapx = zeros(H,W);
validMapx(validMap>0) = 1:nPix;
tVecOut = nan(nPix,numel(tVecIn));
if outType==0
    datWarp = nan(H,W,T);
else
    datWarp = nan(nPix,T);
end

for hh=1:H
    for ww=1:W
        if validMap(hh,ww)>0
            %if hh==9 && ww==10; keyboard; end
            if ~isempty(tVecIn)
                warpTgt = cell(numel(tVecIn),1);
            end
            x0 = nan(1,T);  % warped curve
            c0 = zeros(1,T);  % count the occurrence
            p0 = pathCell{hh,ww}(:,1:2);
            idxValid = p0(:,1)>=1 & p0(:,1)<=T & p0(:,2)>=1 & p0(:,2)<=T;
            p0 = p0(idxValid,:);
            for tt=1:length(p0)
                p_ref = p0(tt,1);
                p_tst = p0(tt,2);
                ix = find(tVecIn==p_ref);
                if ~isempty(tVecIn)
                    if ~isempty(ix)
                        for ii=1:numel(ix)
                            warpTgt{ix(ii)} = union(warpTgt{ix(ii)},p_tst);
                        end
                    end
                end
                if ~isnan(ref(p_ref))
                    if isnan(x0(p_tst))
                        x0(p_tst) = ref(p_ref);
                    else
                        x0(p_tst) = x0(p_tst) + ref(p_ref);
                    end
                    c0(p_tst) = c0(p_tst) + 1;
                end
            end
            p0 = pathCell{hh,ww}(:,3:4);
            idxValid = p0(:,1)>=1 & p0(:,1)<=T & p0(:,2)>=1 & p0(:,2)<=T;
            p0 = p0(idxValid,:);
            for tt=1:length(p0)
                p_ref = p0(tt,1);
                p_tst = p0(tt,2);
                ix = find(tVecIn==p_ref);
                if ~isempty(tVecIn)
                    if ~isempty(ix)
                        for ii=1:numel(ix)
                            warpTgt{ix(ii)} = union(warpTgt{ix(ii)},p_tst);
                        end
                    end
                end
            end
            if ~isempty(tVecIn)
                t4 = tVecIn*0;
                for ee=1:4
                    if isempty(warpTgt{ee})
                        warpTgt{ee} = -1;
                    end
                end
                t4(1) = min(warpTgt{1});
                t4(2) = max(warpTgt{2});
                t4(3) = mean(warpTgt{3});
                t4(4) = mean(warpTgt{4});
                t4(5) = mean(warpTgt{5});
                t4 = round(t4);
                t4(isnan(t4)) = -1;
                tVecOut(validMapx(hh,ww),:) = t4;
            end
            c0(c0==0) = 1;
            if outType==0
                datWarp(hh,ww,:) = x0./c0;
            else
                datWarp(validMapx(hh,ww),:) = x0./c0;
            end
        end
    end
end

end

