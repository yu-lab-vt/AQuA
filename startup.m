addpath(genpath('./src/'));
addpath(genpath('./cfg/'));
addpath(genpath('./tools/'));
% addpath(genpath('./tools/nonrigid/'));

if exist('test','dir')
    addpath(genpath('./test/'));
end

% distcomp.feature( 'LocalUseMpiexec', false );

