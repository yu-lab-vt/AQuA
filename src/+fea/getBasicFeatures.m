function ftsBase = getBasicFeatures(voli0,muPerPix,nEvt,ftsBase)
% getFeatures extract local features from events

% basic features
ftsBase.map{nEvt} = sum(voli0,3);
cc = regionprops(ftsBase.map{nEvt}>0,'Perimeter');
ftsBase.peri(nEvt) = sum([cc.Perimeter])*muPerPix;
cc = regionprops(ftsBase.map{nEvt}>0,'Area');
ftsBase.area(nEvt) = sum([cc.Area])*muPerPix*muPerPix;
ftsBase.circMetric(nEvt) = (ftsBase.peri(nEvt))^2/(4*pi*ftsBase.area(nEvt));

end









