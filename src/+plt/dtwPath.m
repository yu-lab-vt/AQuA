function dtwPath( pathx, idx, type, nTps, col0, lwd0 )
%PLOTPATH Plot the path found by DTW
% path: cell array, each element is a Tx4 matrix giving the start/end coordinates

if ~exist('type','var')
    type = 1;
end

if ~exist('nTps','var')
    nTps = 1e8;
end

if ~exist('lwd0','var')
    lwd0 = 1;
end

if ~exist('col0','var')
    genCol = 1;
else
    genCol = 0;
end

figure;

% vector type
if type==1
    for kk=1:length(idx)
        nn = idx(kk);
        path0 = pathx{nn};
        if genCol
            col0 = rand(1,3);
        end
        for ii=1:size(path0,1)
            x0 = path0(ii,1:2);
            x1 = path0(ii,3:4);
            if max(x1)<=nTps
                plot([x0(2),x1(2)],[x0(1),x1(1)],'color',col0,'LineWidth',lwd0);hold on;
            end
        end
        title(['Node idx: ',num2str(nn)]);
    end
end

% matrix type
colVec = {'b','r','g','k','m'};
if type==2
    for kk=1:size(idx,1)
        path0 = pathx{idx(kk,1),idx(kk,2)};
        %col0 = rand(1,3);
        col0 = colVec{kk};
        for ii=1:size(path0,1)
            x0 = path0(ii,1:2);            
            x1 = path0(ii,3:4);
            plot([x0(2),x1(2)],[x0(1),x1(1)],col0);hold on;
            %plot([x0(2),x1(2)],[x0(1),x1(1)],'color',col0);hold on;
        end
        title(['Idx: ',num2str(kk)]);
    end
end

xlabel('tst');ylabel('ref');

end

