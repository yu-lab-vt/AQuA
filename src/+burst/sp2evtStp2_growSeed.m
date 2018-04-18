function spEvt = sp2evtStp2_growSeed(spEvt,distMat,rise0,sp)

nSeed = max(spEvt);
nSp = numel(rise0);

% seed data structure
% may use results when removing weak seeds
seedNeibLst = cell(nSeed,1);
seedLst = cell(nSeed,1);
for ii=1:nSeed
    idx = find(spEvt==ii);
    tmp = distMat(idx,:);
    seedLst{ii} = idx;
    tmp1 = sum(~isnan(tmp),1);
    neib0 = find(tmp1>0);
    %neib0 = find(~isnan(tmp1));
    seedNeibLst{ii} = setdiff(neib0,idx);
end

% assign pixels to seeds
[~,spOrd] = sort(rise0,'ascend');
wtLst = [];
for ii=1:nSp
    if mod(ii,1000)==0; fprintf('%d\n',ii); end
    idx = spOrd(ii);
    %if idx==347; keyboard; end
    if spEvt(idx)>0
        continue
    end
    suc = 0;
    dist00 = inf(nSeed,1);
    for jj=1:nSeed
        neib0 = seedNeibLst{jj};
        if ~isempty(neib0)
            if sum(seedNeibLst{jj}-idx==0)>0
                suc = 1;
                dist00(jj) = nanmin(distMat(seedLst{jj},idx));
            end
        end
    end
    if suc==1
        [~,jj] = min(dist00);
        spEvt(idx) = jj;
        seedLst{jj} = union(seedLst{jj},idx);
        neibNew = find(~isnan(distMat(idx,:)));
        seedNeibLst{jj} = setdiff(union(seedNeibLst{jj},neibNew),seedLst{jj});
        
        % revisit un-decided super pixels
        for ee=1:1000
            suc1 = 0;
            for kk=1:numel(wtLst)
                idx = wtLst(kk);
                suc2 = 0;
                dist00 = inf(nSeed,1);
                for jj=1:nSeed
                    neib0 = seedNeibLst{jj};
                    if ~isempty(neib0)
                        if sum(seedNeibLst{jj}-idx==0)>0
                            suc2 = 1; suc1 = 1;
                            dist00(jj) = nanmin(distMat(seedLst{jj},idx));
                        end
                    end
                end
                if suc2==1
                    [~,jj] = min(dist00);
                    spEvt(idx) = jj;
                    seedLst{jj} = union(seedLst{jj},idx);
                    neibNew = find(~isnan(distMat(idx,:)));
                    seedNeibLst{jj} = setdiff(union(seedNeibLst{jj},neibNew),seedLst{jj});
                    wtLst = setdiff(wtLst,idx);
                    break
                end
            end
            if suc1==0
                break
            end
        end
        if ee==1000
            fprintf('Sp acquiring error\n')
        end
    else
        % add to un-decided super pixels
        wtLst = union(wtLst,idx);
    end
    if mod(ii,1000)==0
        %plotMe(sp,spEvt);
        %keyboard
        %close all
    end
end

end

function plotMe(sp,spEvt)
voxLst = label2idx(sp);
evt = zeros(size(sp));
evt0 = unique(spEvt);
evt0 = evt0(evt0>0);
nEvt0 = numel(evt0);
for ii=1:nEvt0
    vox0 = voxLst(spEvt==evt0(ii));
    for jj=1:numel(vox0)
        vox00 = vox0{jj};
        evt(vox00) = evt0(ii);
    end
end
ov1 = plt.regionMapWithData(evt,evt*0,0.5); zzshow(ov1);
end

