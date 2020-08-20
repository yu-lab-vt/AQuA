function updtPreset(~,~,f,readTb)
    warning('off','all');
    fh = guidata(f);
    
    if ~exist('readTb','var')
        readTb = 1;
    end
    
    if readTb>0
        cfgFile = 'parameters1.csv';
        cfg = readtable(cfgFile,'ReadVariableNames',true);
        cNames = cfg.Properties.VariableNames;
        cNames = cNames(1,4:end-1);
        %cNames = cfg.Properties.VariableNames(4:end-1);
        fh.preset.String = cNames;
    end
    
    preset = fh.preset.Value;
    opts = util.parseParam(preset,0);
    
    if isfield(opts,'frameRate') && ~isempty(opts.frameRate)
        fh.tmpRes.String = num2str(opts.frameRate);
    end
    if isfield(opts,'spatialRes') && ~isempty(opts.spatialRes)
        fh.spaRes.String = num2str(opts.spatialRes);
    end
    if isfield(opts,'regMaskGap') && ~isempty(opts.regMaskGap)
        fh.bdSpa.String = num2str(opts.regMaskGap);
    end    
    warning('on','all');
end