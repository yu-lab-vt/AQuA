function [resCell,lblMap] = growSeed(dat,dF,resCell,lblMap,lmLoc,lm3Idx,opts,stg)
    % detectGrowRegionOneStepPara grow all seeds by one step in parallel
    % compete between seeds
    
    [H,W,T] = size(dat);
    nLm = numel(lmLoc);
    thrTW = opts.thrTWScl*sqrt(opts.varEst);
    thrARBase = opts.thrARScl*sqrt(opts.varEst);
    tExt = max(opts.maxStp,5);
    
    if ~isfield(opts,'getTimeWindowExt')
        extWin = 50;
    else
        extWin = opts.getTimeWindowExt;
    end
    if ~isfield(opts,'seedRemoveNeib')
        xRm = 2;
    else
        xRm = opts.seedRemoveNeib;
    end
    if ~isfield(opts,'seedNeib')
        sNb = 1;
    else
        sNb = opts.seedNeib;
    end
    
    % prepare data
    %datc = cell(nLm,1);
    for uu=1:numel(lmLoc)
        %if uu==85; keyboard; end
        iSeed = lmLoc(uu);
        if lm3Idx(iSeed)==0  % eaten by others
            continue
        end
        
        if stg==0
            % time window range based on seed and foreground
            [ihS,iwS,itS] = ind2sub([H,W,T],iSeed);
            rgH1 = max(ihS-sNb,1):min(ihS+sNb,H); rgW1 = max(iwS-sNb,1):min(iwS+sNb,W);
            rgH2 = max(ihS-xRm,1):min(ihS+xRm,H); rgW2 = max(iwS-xRm,1):min(iwS+xRm,W);
            rgH3 = max(ihS-xRm,1):min(ihS+xRm,H); rgW3 = max(iwS-xRm,1):min(iwS+xRm,W);
            t0 = itS-extWin;
            t1 = itS+extWin;
            rgT = max(t0-tExt,1):min(t1+tExt,T);
            T1 = numel(rgT);
            
            % time window detection
            x1 = mean(reshape(dat(rgH1,rgW1,rgT),[],T1),1);
            z1 = max(reshape(lm3Idx(rgH2,rgW2,rgT),[],T1),[],1);
            df1 = mean(reshape(dF(rgH1,rgW1,rgT),[],T1),1);
            
            itS1 = itS-min(rgT)+1;
            
            % find time window
            tw1 = burst.getTimeWindow2a(x1,itS1,thrTW,z1,df1,extWin);
            if isempty(tw1)  % seeds need to be merged, try again
                tw1 = burst.getTimeWindow2a(x1,itS1,thrTW,z1*0,df1,extWin);
            end
            if isempty(tw1)  % weak signal, go to baseline
                if numel(df1)>50
                    s00 = sqrt(median((df1(1:end-1)-df1(2:end)).^2)/0.9113);
                    thrAR = s00*opts.thrARScl;
                else
                    thrAR = thrARBase;
                end
                tw1 = burst.getTimeWindow2b(x1,itS1,thrAR,df1,extWin);
            end
            if isempty(tw1)
                lm3Idx(iSeed) = 0;
                continue
            end
            
            % update seed map
            lm3Idx(rgH3,rgW3,tw1.t0a+min(rgT)-1:tw1.t1a+min(rgT)-1) = 0;
            
            % initialize res
            res = [];
            res.charxIn = x1;
            res.tw = tw1;
            res.iSeed = iSeed;
            res.rgH = rgH1;
            res.rgW = rgW1;
            res.rgT = rgT;
            res.MovSz = [H,W,T];
            res.cont = 1;
            res.stg = 0;
            resCell{uu} = res;
        else
            % based on current res.fiux, ** rgT is unchanged **
            % update location related items in res
            res = resCell{uu};
            if ~isempty(res) && res.cont>0
                fiux = res.fiux;
                pixBad = res.pixBad;
                rgH0 = res.rgH;
                rgW0 = res.rgW;
                
                % extend window by 1
                rgH1 = max(min(rgH0)-1,1):min(max(rgH0)+1,H);
                rgW1 = max(min(rgW0)-1,1):min(max(rgW0)+1,W);
                res.rgH = rgH1;
                res.rgW = rgW1;
                
                % update fiux
                [h0,w0] = ind2sub([numel(rgH0),numel(rgW0)],fiux);
                h0a = h0+min(rgH0)-min(rgH1);
                w0a = w0+min(rgW0)-min(rgW1);
                res.fiux = sub2ind([numel(rgH1),numel(rgW1)],h0a,w0a);
                
                % update pixBad
                [h0,w0] = ind2sub([numel(rgH0),numel(rgW0)],pixBad);
                h0a = h0+min(rgH0)-min(rgH1);
                w0a = w0+min(rgW0)-min(rgW1);
                res.pixBad = sub2ind([numel(rgH1),numel(rgW1)],h0a,w0a);
                resCell{uu} = res;
            else
                continue
            end
        end
        %datc{uu} = dat(res.rgH,res.rgW,res.rgT);
    end
    
    % fit around seeds
    for uu=1:nLm
    %parfor(uu=1:nLm,4)
        res = resCell{uu};
        if isempty(res) || res.cont==0
            continue
        end
        resCell{uu} = burst.detectGrowSp(dat(res.rgH,res.rgW,res.rgT),res,opts);
        %resCell{uu} = burst.detectGrowSp(datc{uu},res,opts);
    end
    
    % grow seeds
    for uu=1:nLm
        res = resCell{uu};
        if isempty(res) || res.cont==0
            continue
        end
        isGoodSum = 0;
        rgH = res.rgH; rgW = res.rgW; rgT = res.rgT;
        for ii=1:numel(res.pixNew)
            ix0 = res.pixNew(ii);
            ihw0 = res.fiux(ix0);
            [ih0,iw0] = ind2sub([numel(rgH),numel(rgW)],ihw0);
            twx = res.twMap(ix0,:);
            if twx(1)==0
                continue
            end
            twx = twx+min(rgT)-1;
            ih0 = ih0+min(rgH)-1;
            iw0 = iw0+min(rgW)-1;
            lblCur = lblMap(ih0,iw0,twx(3):twx(4));
            isGood = nanmax(lblCur)==0;
            if isGood  % ignore competition
                isGoodSum = 1;
                lblCur = lblMap(ih0,iw0,twx(3):twx(4));
                t0 = find(lblCur(1:twx(5)-twx(3)+1)>0,1,'last');
                t1 = find(lblCur(twx(5)-twx(3)+1:end)>0,1);
                if isempty(t0)
                    t0 = 1;
                end
                if isempty(t1)
                    t1 = numel(lblCur);
                else
                    t1 = twx(5)-twx(3)+1+t1-1;
                end
                lblCur(t0:t1) = lblCur(t0:t1)*0+uu;
                lblMap(ih0,iw0,twx(3):twx(4)) = uint32(lblCur);
            else  % lose the competition
                res.pixBad = union(res.pixBad,ihw0);
            end
        end
        if isGoodSum==0
            res.cont = 0;
        end
        resCell{uu} = res;
    end
    
end




