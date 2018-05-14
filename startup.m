addpath(genpath('./src/'));
addpath(genpath('./cfg/'));
addpath(genpath('./tools/'));

if exist('test','dir')
    addpath(genpath('./test/'));
end

% javaclasspath('-v1')
% javaclasspath('.\tools\FASP\')