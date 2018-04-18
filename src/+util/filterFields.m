function fts = filterFields(fts,evtSel)
% filter fields in events
% support: 2D matrix, 3D matrix, 2D cell array, empty, non feature vector

if isstruct(fts)
    fn = fieldnames(fts);
    for ii=1:numel(fn)
        fts.(fn{ii}) = util.filterFields(fts.(fn{ii}),evtSel);        
    end    
else
    sz = size(fts);
    if isempty(fts)
        return
    end
    
    % 2D cell
    if iscell(fts)
        if sz(1)==numel(evtSel)
            fts = fts(evtSel,:);
            return
        end
        if sz(2)==numel(evtSel)
            fts = fts(:,evtSel);
        end
        return
    end
    
    % 3D matrix
    if numel(sz)==3
        if sz(1)==numel(evtSel)
            fts = fts(evtSel,:,:);
        end
        if sz(2)==numel(evtSel)
            fts = fts(:,evtSel,:);
        end
        if sz(3)==numel(evtSel)
            fts = fts(:,:,evtSel);
        end
        return
    end
    
    % 2D matrix
    if numel(sz)==2 && (sz(1)==numel(evtSel) || sz(2)==numel(evtSel))
        if sz(1)==numel(evtSel)
            fts = fts(evtSel,:);
        else
            fts = fts(:,evtSel);
        end
        return
    end
    
    % for others, do not filter    
    
end

end


