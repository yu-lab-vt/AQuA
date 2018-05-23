function updtMskSld(~,~,f,rr)
    % update slider
    
    fh = guidata(f);
    
    gap0 = [0.001 0.1];
    
    [H,W] = size(rr.datAvg);
    
    fh.sldMskThr.Min = 0; %min(rr.datAvg(:));
    fh.sldMskThr.Max = 1; %max(rr.datAvg(:));
    fh.sldMskThr.SliderStep = gap0;
    fh.sldMskThr.Value = rr.thr;
    
    fh.sldMskMinSz.Min = 0;
    fh.sldMskMinSz.Max = log10(H*W*1.1);
    fh.sldMskMinSz.SliderStep = gap0;
    fh.sldMskMinSz.Value = log10(rr.minSz);
    
    fh.sldMskMaxSz.Min = 0;
    fh.sldMskMaxSz.Max = log10(H*W*1.1);
    fh.sldMskMaxSz.SliderStep = gap0;
    fh.sldMskMaxSz.Value = log10(rr.maxSz);    
end
