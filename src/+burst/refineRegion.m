function [vox1,htMap0,fiu0,z] = refineRegion(df0,e0,nn,...
        stdEst,delta,osTb,mthdSolver,mthdZ,mthdClean)
    % refineRegion grow region from data
    % Use delta F as input
    %
    % mthdSolver: three algorithms to grow regions
    % mthdZ: two algorithms to find z score
    %
    % Matlab version has higher accuracy, and is faster for larger regions
    % Use the inner part as seed further accelarate the code
    %
    
    if ~exist('mthdZ','var')
        mthdZ = 0;
    end
    if ~exist('mthdSolver','var')
        mthdSolver = 1;
    end
    [H,W,~] = size(df0);
    
    % FIXME imputation, set to NaN in real data, or does not matter?
    idxBad = find(e0>0 & e0~=nn);
    e0(idxBad) = 0;
    df0(idxBad) = randn(numel(idxBad),1)*stdEst;
    fiu0 = sum(e0,3)>0;
    
    % region to refine
    fiu0Di = imdilate(fiu0,strel('square',delta));
    
    % core region that is more reliable
    fiu0Er = imerode(fiu0,strel('square',delta));
    
    d0Vec = reshape(df0,[],size(df0,3));        
    if mthdZ==0  % find local maximum as seeds
        zMap0 = zeros(size(fiu0));
        stdMap = std(df0,0,3);
        stdMap(fiu0Di==0) = -1;
        cntMap = zeros(H,W);  % one pixel with z scores from multiple seeds
        
        stdMapSmo = imgaussfilt(stdMap,2);
        stdLm = imregionalmax(stdMapSmo);
        stdLm(fiu0Di==0) = 0;
        seedIdx = find(stdLm>0);
        
        dist0 = bwdist(stdLm);
        dist0(fiu0Di==0) = 0;
        dhw = ceil(max(dist0(:)));
        idxMap = reshape(1:H*W,H,W);
        
        for ii=1:numel(seedIdx)
            [ih0,iw0] = ind2sub([H,W],seedIdx(ii));
            rgh0 = max(ih0-dhw,1):min(ih0+dhw,H);
            rgw0 = max(iw0-dhw,1):min(iw0+dhw,W);
            
            pixSel = reshape(idxMap(rgh0,rgw0),[],1);
            pixSel = pixSel(fiu0Di(pixSel)>0);
            cntMap(pixSel) = cntMap(pixSel)+1;
            
            charx0 = zscore(mean(d0Vec(pixSel,:),1),0,2);
            d0Sel = zscore(d0Vec(pixSel,:),0,2);
            r0Vec = mean(d0Sel.*charx0,2);
            zMap0(pixSel) = zMap0(pixSel) + stat.getFisherTrans(r0Vec,size(e0,3));
        end
        zMap0(cntMap==0) = nan;
        cntMap(cntMap==0) = 1;
        zMap0 = zMap0./cntMap;  % take average
    end
    if mthdZ==1  % use all pixels, ignore propagation, for low SNR
        % initial curve is important
        zMap0 = nan(size(fiu0));
        pixSel = find(fiu0Er>0);  % inner parts are more reliable
        pixAll = find(fiu0>=0);
        if numel(pixSel)<10  % FIXME
            pixSel = find(fiu0>0);
        end
        charx0 = zscore(mean(d0Vec(pixSel,:),1),0,2);
        d0Sel = zscore(d0Vec(pixAll,:),0,2);
        r0Vec = mean(d0Sel.*charx0,2);
        zMap0(pixAll) = getFisherTrans(r0Vec,size(e0,3));
    end
    
    % HTRG
    vMap0 = fiu0Di;
    zMap0(isnan(zMap0)) = -10;
    if mthdSolver==0  % Java code from FASP
        res0 = HTregionGrowingSuper(zMap0,vMap0,2,4,4,0);
        htMap00 = double(res0.connDmIDmap);
        htMap00 = htMap00.*vMap0;
        htMap00(fiu0Er>0) = 1;
    end
    if mthdSolver==1  % Matlab
        [htMap00,~,zOutMap] = burst.htrg2(zMap0,fiu0Er,vMap0,osTb,1,2,4,4);
    end
    if mthdSolver==2  % Matlab, do not specify seed
        [htMap00,~,zOutMap] = burst.htrg2(zMap0,[],vMap0,osTb,1,2,4,4);
    end
    
    z = max(zOutMap(:));
    
    % FIXME morphology operation strength should depend on SNR
    if mthdClean>0
        htMap00 = bwareaopen(htMap00>0,8);
        htMap00 = imfill(htMap00,'holes');
        %htMap00 = imclose(htMap00,strel('square',3));
        %htMap00 = imopen(htMap00,strel('square',3));
    end
    
    % choose desired component
    cc = bwconncomp(htMap00>0,4);
    htMap0 = zeros(size(fiu0));
    lbl = labelmatrix(cc);
    lblx = lbl(fiu0>0 & lbl>0);
    
    % for new pixels. find its nearest existing neighbor for curves
    if ~isempty(lblx)
        lblSel = mode(lblx);
        htMap0(cc.PixelIdxList{lblSel}) = 1;
        %htMap0 = 1*(htMap00>0);
        
        [ih0,iw0] = find(htMap0>0 & fiu0==0);
        fiuInter = htMap0>0 & fiu0>0;
        [ih1,iw1] = find(fiuInter>0);
        e1 = e0.*htMap0;  % remove bad voxels
        for ii=1:numel(ih0)
            [~,ix0] = min((ih0(ii)-ih1).^2+(iw0(ii)-iw1).^2);
            e1(ih0(ii),iw0(ii),:) = e1(ih1(ix0),iw1(ix0),:);
        end
        vox1 = find(e1>0);
    else
        vox1 = [];
    end    
end




