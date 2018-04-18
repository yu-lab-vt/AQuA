function [pVal,difx,vidIdxNew] = getRegionScore( vidVST,vidIdx,loc,varEst,mthd)
%GETREGIONSCORE Compute z-score for each region
% simple case: assume background is uniform

if ~exist('mthd','var')
    mthd = 0;
end

lMax = max(vidIdx(:));
[H,W,T] = size(vidVST);
difx = zeros(1,lMax);

vidIdxNew = vidIdx;

%% order statistics
if mthd==0
    tmp = load('ostbl_4_50_4_100.mat');
    difMean = tmp.difMean;
    difVar = tmp.difVar;
    pVal = nan(1,lMax);
    [x,y,z] = ndgrid(-2:2);
    % ignore the direct neighbor
    SEInner = sqrt(x.^2 + y.^2 + z.^2) <= 1;
    SEOuter = sqrt(x.^2 + y.^2 + z.^2) <= 3;
    for nn=1:lMax
        if mod(nn,10000)==0
            fprintf('N: %d\n',nn)
        end
        loc0 = loc{nn};
        if isempty(loc0)
            continue
        end
        [ix,iy,iz] = ind2sub([H,W,T],loc0);
        xMin = max(min(ix)-2,1); xMax = min(max(ix)+2,H);
        yMin = max(min(iy)-2,1); yMax = min(max(iy)+2,W);
        zMin = max(min(iz)-2,1); zMax = min(max(iz)+2,T);
        vidIdx0 = vidIdx(xMin:xMax,yMin:yMax,zMin:zMax);
        vidEvt0 = vidIdx0==nn;
        vidVST0 = vidVST(xMin:xMax,yMin:yMax,zMin:zMax);
        
        if sum(vidEvt0(:))>0
            tmpDiInner = imdilate(vidEvt0,SEInner);
            tmpDiOuter = imdilate(vidEvt0,SEOuter);
            tmpDiOuter(tmpDiInner>0) = 0;
            grpPos = vidVST0(vidEvt0>0);
            grpNeg = vidVST0(tmpDiOuter>0 & vidIdx0==0);
            
            %             posL = min(max(length(grpPos),4),50);
            %             negL = min(max(length(grpNeg),4),100);
            %             os0 = mean(grpPos) - mean(grpNeg);
            %             osNullMean = difMean(posL,negL)*sqrt(varEst);
            %             osNullVar = difVar(posL,negL)*varEst;
            
            posL = max(length(grpPos),4);
            negL = max(length(grpNeg),4);
            if posL>50
                rt = posL/50;
                posL = 50;
            else
                rt = 1;
            end
            negL = min(round(negL/rt),100);
            os0 = mean(grpPos) - mean(grpNeg);
            %             try
            osNullMean = difMean(posL,negL)*sqrt(varEst);
            %             catch
            %                 keyboard
            %             end
            osNullVar = difVar(posL,negL)*varEst/rt;
            
            pVal(nn) = 1-normcdf(os0,osNullMean,sqrt(osNullVar));
            difx(nn) = os0;
        end
    end
end

%% order statistics, temporal only
if mthd==1
    tmp = load('ostbl_4_50_4_100.mat');
    difMean = tmp.difMean;
    difVar = tmp.difVar;
    pVal = nan(1,lMax);
    
    % ignore the direct neighbor
    for nn=1:lMax
        if mod(nn,1000)==0
            fprintf('N: %d\n',nn)
        end
        loc0 = loc{nn};
        if isempty(loc0)
            continue
        end
        [ix,iy,iz] = ind2sub([H,W,T],loc0);
        xMin = max(min(ix)-1,1); xMax = min(max(ix)+1,H);
        yMin = max(min(iy)-1,1); yMax = min(max(iy)+1,W);
        zMin = max(min(iz)-5,1); zMax = min(max(iz)+5,T);
        vidIdx0 = vidIdx(xMin:xMax,yMin:yMax,zMin:zMax);
        vidEvt0 = vidIdx0==nn;
        vidVST0 = vidVST(xMin:xMax,yMin:yMax,zMin:zMax);
        
        if sum(vidEvt0(:))>0
            vidNeibVld = vidIdx0==0;
            mask0 = repmat(sum(vidEvt0,3)>0,1,1,zMax-zMin+1);
            vidNeibVld = vidNeibVld.*mask0;
            grpPos = vidVST0(vidEvt0>0);
            grpNeg = vidVST0(vidNeibVld>0);
            
            posL = max(length(grpPos),4);
            negL = max(length(grpNeg),4);
            if posL>50
                rt = posL/50;
                posL = 50;
            else
                rt = 1;
            end
            negL = min(round(negL/rt),100);
            os0 = mean(grpPos) - mean(grpNeg);
            osNullMean = difMean(posL,negL)*sqrt(varEst);
            osNullVar = difVar(posL,negL)*varEst/rt;
            
            pVal(nn) = 1-normcdf(os0,osNullMean,sqrt(osNullVar));
            difx(nn) = os0;
        end
    end
end

%% order statistics, temporal only, reselect time points
if mthd==2
    tmp = load('ostbl_4_50_4_100.mat');
    difMean = tmp.difMean;
    difVar = tmp.difVar;
    pVal = nan(1,lMax);
    
    % ignore the direct neighbor
    for nn=1:lMax
        if mod(nn,1000)==0
            fprintf('N: %d\n',nn)
        end
        loc0 = loc{nn};
        if isempty(loc0)
            continue
        end
        [ix,iy,iz] = ind2sub([H,W,T],loc0);
        xMin = max(min(ix)-1,1); xMax = min(max(ix)+1,H);
        yMin = max(min(iy)-1,1); yMax = min(max(iy)+1,W);
        zMin = max(min(iz)-5,1); zMax = min(max(iz)+5,T);
        vidIdx0 = vidIdx(xMin:xMax,yMin:yMax,zMin:zMax);
        vidEvt0 = vidIdx0==nn;
        vidVST0 = vidVST(xMin:xMax,yMin:yMax,zMin:zMax);
        
        if sum(vidEvt0(:))>0
            % remove weak signals
            vidNeibVld = vidIdx0==0;
            mask0 = repmat(sum(vidEvt0,3)>0,1,1,zMax-zMin+1);
            vidNeibVld = vidNeibVld.*mask0;
            bgMean = mean(vidVST0(vidNeibVld>0));
            
            % signal intensity across time
            vidVST1 = vidVST0;
            vidVST1(vidIdx0>0 & vidIdx0~=nn) = NaN;
            vidVST1(mask0==0) = NaN;
            vidVST1Vec = reshape(vidVST1,[],size(vidVST1,3));
            sigBgMean = nanmean(vidVST1Vec,1);
            
            sigMax = max(sigBgMean);
            idxSig = (sigBgMean-bgMean)>0.3*(sigMax-bgMean);
            for tt=1:size(vidIdx0,3)
                tmp = vidIdx0(:,:,tt);
                if idxSig(tt)==0
                    tmp(tmp==nn) = 0;
                    vidIdx0(:,:,tt) = tmp;
                end
            end
            
            % update index map
            vidIdxNew(xMin:xMax,yMin:yMax,zMin:zMax) = vidIdx0;
            
            % find neighbors
            vidEvt0 = vidIdx0==nn;            
            if sum(vidEvt0(:))>0
                vidNeibVld = vidIdx0==0;
                mask0 = repmat(sum(vidEvt0,3)>0,1,1,zMax-zMin+1);
                vidNeibVld = vidNeibVld.*mask0;
                grpPos = vidVST0(vidEvt0>0);
                grpNeg = vidVST0(vidNeibVld>0);
                
                posL = max(length(grpPos),4);
                negL = max(length(grpNeg),4);
                if posL>50
                    rt = posL/50;
                    posL = 50;
                else
                    rt = 1;
                end
                negL = min(round(negL/rt),100);
                
                % order statistics
                os0 = mean(grpPos) - mean(grpNeg);
                osNullMean = difMean(posL,negL)*sqrt(varEst);
                osNullVar = difVar(posL,negL)*varEst/rt;
                
                pVal(nn) = 1-normcdf(os0,osNullMean,sqrt(osNullVar));
                difx(nn) = os0;
            end
        end
    end
end

%% brightest patch for each event
% !! introduced bias
if mthd==3
    maxGrp = cell(lMax,1);
    maxVal = zeros(lMax,1);
    for t=1:T
        vidIdx_t = vidIdx(:,:,t);
        vidVST_t = vidVST(:,:,t);
        idxEvt_t = unique(vidIdx_t(:)); idxEvt_t = idxEvt_t(idxEvt_t>0);
        for ii=1:length(idxEvt_t)
            idx = idxEvt_t(ii);
            pix = find(vidIdx_t==idx);
            m = mean(vidVST_t(pix));
            if m>maxVal(idx)
                maxVal(idx) = m;
                maxGrp{idx} = vidVST_t(pix);
            end
        end
    end
    
    pVal = nan(lMax,1);
    for n=1:lMax
        val = maxGrp{n};
        if ~isempty(val)
            varEstGrp = varEst;
            [~,p] = ztest(val,0,sqrt(varEstGrp));
            pVal(n) = p;
        end
    end
end

end






