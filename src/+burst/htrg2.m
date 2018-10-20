function [rMapConn,rMap,zOutMap] = htrg2(zMap,seedMap,validMap,osTb,seedThr,regThr,minSize,nConn)
    % htrg2 implements hypothesis testing region growing
    % seedMap can be a binary region, a pixel or empty
    %
    
    if ~exist('seedThr','var')
        seedThr = 2;
    end
    if ~exist('regThr','var')
        regThr = 4;
    end
    if ~exist('minSize','var')
        minSize = 4;
    end
    if ~exist('nConn','var')
        nConn = 4;
    end
    if sum(seedMap(:)>0)==0
        seedMap = [];
    end
    
    xValid = validMap;
    zOutMap = zeros(size(zMap));
    rMap = zeros(size(zMap));
    
    if ~isempty(seedMap)
        [rMap,z0] = burst.htrg2Core(zMap,seedMap,xValid,osTb,1,nConn);
        xValid(rMap>0) = 0;
        zOutMap(rMap>0) = z0;
    end
    
    nn = 1;
    while 1
        xLst = find(xValid>0);
        if isempty(xLst)
            break
        end
        [x,ix] = max(zMap(xLst));
        if x<seedThr
            break
        end
        [rMap0,z0] = burst.htrg2Core(zMap,xLst(ix),xValid,osTb,nn,nConn);
        xValid(rMap0>0) = 0;
        if z0>regThr
            rMap(rMap0>0) = nn;
            zOutMap(rMap0>0) = z0;
            nn = nn+1;
        end        
    end
    
    % fill small holes (<8)
    X = rMap>0;
    X = bwareaopen(X,minSize);
    Xhole = imfill(X,'holes')-X;
    XholeSmall = Xhole - bwareaopen(Xhole,16);
    X = X+XholeSmall;
    
    % connected component
    cc = bwconncomp(X,nConn);
    rMapConn = labelmatrix(cc);    
    
end











