function [locy,locx,evtRadiuses,circs,circsPool] = getLocInfo(evtLst,movSize)
H = movSize(1);
W = movSize(2);
T = movSize(3);

numEvt = length(evtLst);
locy = zeros(numEvt,1);     % event center y-coordinate
locx = zeros(numEvt,1);     % event center x-coordinate
loct = zeros(numEvt,1);
evtRadiuses = zeros(numEvt,1);  % event radius: all events are viewed as circles
evtCells = cell(numEvt,1);  % event coordinates (2D)
rgVec = zeros(numEvt,2);

for ii=1:numel(evtLst)
    [locyAll,locxAll, loctAll] = ind2sub([H,W,T],evtLst{ii});
    rgVec(ii,1) = min(loctAll);
    rgVec(ii,2) = max(loctAll);
    uniLoc = unique([locyAll,locxAll],'rows');
    evtCells{ii} = (uniLoc(:,2)-1)*H+uniLoc(:,1);
    locy(ii) = round(mean(uniLoc(:,1)));
    locx(ii) = round(mean(uniLoc(:,2)));
    loct(ii) = min(loctAll);
    evtRadiuses(ii) = sqrt(length(evtCells{ii})/pi);
end

% shapes in each frame
circs = cell(T,1);
for tt=1:T
    tmp = [];
    idx = find(rgVec(:,1)<=tt & rgVec(:,2)>=tt);
    if ~isempty(idx)
        tmp.loc = [locx(idx),locy(idx)];
        tmp.rad = evtRadiuses(idx);
        circs{tt} = tmp;
    end
end

circsPool = [];
circsPool.loc = [locx,locy];
circsPool.rad = evtRadiuses;


end
