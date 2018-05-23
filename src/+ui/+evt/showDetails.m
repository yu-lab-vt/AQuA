function showDetails(~,~,f)
    
    % use a GUI to display detailed features
    ftb = getappdata(f,'featureTable');
    btSt = getappdata(f,'btSt');
    lst = btSt.evtMngrMsk;
    ftb00 = ftb{:,1};
    Event_favorite = ftb00(:,lst);
    ftsRowName = ftb.Row;
    
    % initialize GUI
    figFav = getappdata(f,'figFav');
    if isempty(figFav) || ~isvalid(figFav)
        figFav = figure('MenuBar','none','Toolbar','none','NumberTitle','off');
        figFav.Name = 'Features for favorite events';
        Pix_SS = get(0,'screensize');
        h0 = Pix_SS(4)/2-350; w0 = Pix_SS(3)/2-350;  % 50 is taskbar size
        figFav.Position = [w0,h0,700,700];
        b00 = uix.VBox('Parent',figFav);
        uitable(b00,'Tag','evtFavTab');
        fh00 = guihandles(figFav);
        guidata(figFav,fh00);
        setappdata(f,'figFav',figFav);
    end
    
    % put to table
    fh00 = guidata(figFav);
    tb00 = fh00.evtFavTab;
    tb00.Data = [ftsRowName, num2cell(Event_favorite)];
    nCol = size(tb00.Data,2);
    colWidth = cell(1,nCol);
    colWidth{1} = 270;
    for ii=2:nCol
        colWidth{ii} = 'auto';
    end
    tb00.ColumnWidth = colWidth;
    
end