function opts = overrideParam(opts,optsIn)
%evalParam evaluate parameters

% override
if ~isempty(optsIn)
    ss = fieldnames(optsIn);
    for ii=1:length(ss)
        opts.(ss{ii}) = optsIn.(ss{ii});
    end
end

end






