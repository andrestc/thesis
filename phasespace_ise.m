function d = phasespace_ise( P, Q, d, tau, h )

    P = zscore(P);
    Q = zscore(Q);
    
    P = phasespace(P, d, tau);
    Q = phasespace(Q, d, tau);
    
    h = ones(1, size(Q,2)) * h;

    d = ISE(P, Q, h, h);

end