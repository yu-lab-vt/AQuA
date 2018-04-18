function opts = evalParam(optsLit)
%evalParam evaluate parameters

opts = [];
f00 = fieldnames(optsLit);
for ii=1:length(f00)
    x1 = f00{ii};
    x2 = optsLit.(x1);
    if isempty(x2)
        opts.(x1) = [];  % empty parameter
    else
        [x2Num,x2Stat] = str2num(x2);
        if x2Stat==1
            opts.(x1) = x2Num;  % numeric
        else
            try
                opts.(x1) = eval(x2);  % evaluate a command
            catch
                opts.(x1) = x2;  % string
            end
        end
    end
end

end






