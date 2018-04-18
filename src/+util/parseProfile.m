function [ fidVec,opts,optsLit,inDir,outDir ] = parseProfile( f0 )
%PARSEPROFILE Process running profile

% file list
fidx = fopen(f0);
F = textscan(fidx,'%s','Delimiter','\n');
fclose(fidx);

% detection options
optsLit = [];
fidVec = cell(0);  % each item: file name without postfix;resonant;spatial res.;temporal res.
for ii=1:length(F{1})
    xx = F{1}{ii};
    if isempty(xx)
        continue
    end
    xx = strtrim(xx);
    if isempty(xx) || xx(1)=='%'
        continue
    end
    xxc = strsplit(xx,{'=','%'});
    if length(xxc)>=2
        x1 = strtrim(xxc{1});
        x2 = strtrim(xxc{2});
        if strcmp(x1,'dirIn')
            inDir = x2;
            continue
        end
        if strcmp(x1,'dirOut')
            outDir = x2;
            continue
        end    
        if strcmp(x1,'dat')
            nMov = length(fidVec);
            fidVec{nMov+1} = x2;
            continue
        end
        optsLit.(x1) = x2;      
    end
end

opts = [];
if ~isempty(optsLit)
    opts = util.evalParam(optsLit);
end

end

