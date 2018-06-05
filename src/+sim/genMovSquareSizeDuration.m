function L1 = genMovSquareSizeDuration()
    % genMovSquareSizeDuration generate randomly located sparklings
    % without noise, temporal kernel and spatial kernel
    % with same shape and duration
    
    sideLen = 2;
    duraLen = 2;

    dh = sideLen*2+2;
    dw = sideLen*2+2;
    dt = duraLen*2+2;
    
    H = 512;
    W = 512;
    T = 300;

    N = 1000;

    hidx = randi([sideLen+2,H-sideLen-2],N*2,1);
    widx = randi([sideLen+2,W-sideLen-2],N*2,1);
    tidx = randi([duraLen+3,T-duraLen-3],N*2,1);
    idx = sub2ind([H,W,T],hidx,widx,tidx);

    L = zeros(H,W,T);
    L(idx) = 1:numel(idx);
    L1 = zeros(H,W,T);
    nEvt = 1;
    for ii=1:numel(idx)
        if L(idx(ii))==0
            continue
        end
        h0 = hidx(ii);
        w0 = widx(ii);
        t0 = tidx(ii);
        hrg = max(h0-dh,1):min(h0+dh,H);
        wrg = max(w0-dw,1):min(w0+dw,W);
        trg = max(t0-dt,1):min(t0+dt,T);
        L(hrg,wrg,trg) = 0;
        hrg = max(h0-sideLen,1):min(h0+sideLen,H);
        wrg = max(w0-sideLen,1):min(w0+sideLen,W);
        trg = max(t0-duraLen,1):min(t0+duraLen,T);
        L1(hrg,wrg,trg) = nEvt;
        nEvt = nEvt+1;
        if nEvt>N
            break
        end
    end 
    
end

