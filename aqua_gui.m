function aqua_gui(res,dbg)
    %AQUA_GUI GUI for AQUA
    
    startup;
    randomseed = load('random_Seed.mat');
    rng(randomseed.s);
    
    if ~exist('dbg','var')
        dbg = 0;
    end
    
    f = figure('Name','AQUA','MenuBar','none','Toolbar','none',...
        'NumberTitle','off','Visible','off');
    
    ui.com.addCon(f,dbg);
    if exist('res','var') && ~isempty(res)
        ui.proj.prep([],[],f,2,res);
    end
    f.Visible = 'on';
    
end




















