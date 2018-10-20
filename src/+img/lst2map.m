function xMap = lst2map(lst,sz)
    
    xMap = zeros(sz);
    for ii=1:numel(lst)
        xMap(lst{ii}) = ii;
    end
    
end