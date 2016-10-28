function [v] = ISE(P,Q, wsP,wsQ, kdeP, kdeQ)
% Computes the distance ISE between P and Q according to the bandwidths
% wsP and wsQ.

    if nargin == 4
        Vpp = sum(KDE(P, P, wsP))/size(P, 1);
        Vqq = sum(KDE(Q, Q, wsQ))/size(Q, 1);
    else
        Vpp = sum(kdeP)/size(P,1);
        Vqq = sum(kdeQ)/size(Q,1);
    end
    
    Vpq = sum(KDE(P, Q, (wsP+wsQ)/2))/size(P, 1);
    
    v = Vpp - 2*Vpq + Vqq;
    
end