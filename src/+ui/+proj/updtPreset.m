function updtPreset(~,~,f)
    
    fh = guidata(f);
    cfgFile = 'parameters1.csv';
    cfg = readtable(cfgFile,'ReadVariableNames',false);
    cNames = cfg{1,4:end-1};
    %cNames = cfg.Properties.VariableNames(4:end-1);
    fh.preset.String = cNames;
    
end