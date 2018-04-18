function getFeatureTemplate()

fts = [];
T = 2;  % template

% default values
fts.evtT = 0;
fts.map = zeros(10,10);
fts.peri = 0;
fts.area = 0;
fts.size = 0;
fts.circMetric = 0;
fts.evtBri = 0;

fts.propDist = zeros(T,4);
fts.propDistOrg = zeros(T,4);
fts.propDistComp = cell(T,1);
fts.propDirection4 = [0 0 0 0];
fts.propDirection2 = [0 0];
fts.propDistDiag = zeros(T,4);
fts.propSpeedMax = 0;

fts.propDistS = zeros(T,4);
fts.propDistOrgS = zeros(T,4);
fts.propDistCompS = cell(T,1);
fts.propDirection4S = [0 0 0 0];
fts.propDirection2S = [0 0];
fts.propDistDiagS = zeros(T,4);
fts.propSpeedMaxS = 0;

fts.propPixInc = zeros(T,1);
fts.propPixDec = zeros(T,1);
fts.propPixChangeRatio = zeros(T,1);
fts.propPixChangeRatioCurrent = zeros(T,1);

end


