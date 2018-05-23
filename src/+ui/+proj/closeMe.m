function closeMe(~,~,f)
    % Close request function
    % to display a question dialog box
    
    selection = questdlg('Quit AQUA?',...
        'Close Request Function',...
        'Yes','No','No');
    switch selection
        case 'Yes'
            figFav = getappdata(f,'figFav');
            if ~isempty(figFav) && isvalid(figFav)
                delete(figFav);
            end
            delete(f)
        case 'No'
            return
    end
end