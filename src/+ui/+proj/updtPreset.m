function updtPreset(~,~,f)
    
    fh = guidata(f);
    cfgFile = 'parameters1.csv';
    cfg = readtable(cfgFile);
    cNames = cfg.Properties.VariableNames(4:end-1);
    fh.preset.String = cNames;
    
end