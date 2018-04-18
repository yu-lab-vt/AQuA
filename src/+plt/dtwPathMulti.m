function dtwPathMulti( pathx, idx, type )
%PLOTPATH Plot the path found by DTW
% path: cell array, each element is a Tx4 matrix giving the start/end coordinates

if ~exist('type','var')
    type = 1;
end

figure;

% vector type
if type==1
    for kk=1:length(idx)
        nn = idx(kk);
        path0 = pathx{nn};
        col0 = rand(1,3);
        for ii=1:size(path0,1)
            x0 = path0(ii,1:2);
            x1 = path0(ii,3:4);
            plot([x0(2),x1(2)],[x0(1),x1(1)],'color',col0);hold on;title(['Node idx: ',num2str(nn)]);
        end
    end
end

% multiple conditions
if type==2
    if length(pathx(:))~=length(idx)
        error('One path in one condition\n');
    end
    for kk=1:length(idx)
        path0 = pathx{kk}{idx(kk)};
        col0 = rand(1,3);
        for ii=1:size(path0,1)
            x0 = path0(ii,1:2);
            x1 = path0(ii,3:4);
            plot([x0(2),x1(2)],[x0(1),x1(1)],'color',col0); hold on
        end
    end
end

% multiple conditions, path is a 2D cell
if type==3
    for kk=1:length(idx)
        path0 = pathx{idx(kk)};
        col0 = rand(1,3); 
        %col0 = col0/max(col0);
        pathLen = size(path0,1);
        idxTxt = randi(pathLen);
        for ii=1:pathLen
            x0 = path0(ii,1:2)+rand(1,2)*0.02;
            x1 = path0(ii,3:4)+rand(1,2)*0.02;
            plot([x0(2),x1(2)],[x0(1),x1(1)],'color',col0); hold on
            if ii==idxTxt
                text(x0(2)+rand()*1,x0(1)+rand()*1,num2str(kk),'Color',col0);
            end
        end
    end
end

xlabel('tst');ylabel('ref');

end

