function build_graphCutMex
% mex command to build graphCutMex

codePath = 'ibfs';

srcFiles = { 'graphCutMex.cpp', ...
            fullfile(codePath, 'ibfs.cpp') };
allFiles = '';
for iFile = 1 : length(srcFiles)
    allFiles = [allFiles, ' ', srcFiles{iFile}];
end

cmdLine = ['mex ', allFiles, ' -output graphCutMex -largeArrayDims '];
eval(cmdLine);
