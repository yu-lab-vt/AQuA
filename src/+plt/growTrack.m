function growTrack(dat,twMap,fiux)
%GROWTRACK Show growing results

[H,W,T] = size(dat);

evtMap = zeros(H,W,T);
for ii=1:numel(fiux)
    [ih0,iw0] = ind2sub([H,W],fiux(ii));
    tw0 = twMap(ii,:);
    if tw0(1)==0
        fprintf('%d %d\n',ih0,iw0)
        continue
    end
    evtMap(ih0,iw0,tw0(1):tw0(2)) = 0.3;
    evtMap(ih0,iw0,tw0(3):tw0(4)) = 0.7;
end
tmp = zeros(H,W,3,T);
tmp(:,:,1,:) = evtMap;
tmp(:,:,2,:) = dat;
oldzzshow(tmp);

end

