function r = calcLinkBudget(L, alpha, nSplice, nConn, lSplice, lConn, Ptx, sens, safety)
%CALCLINKBUDGET Optical link budget.
%   Total loss = alpha*L + nSplice*lSplice + nConn*lConn
%   Prx        = Ptx - Total loss
%   Margin     = Prx - sensitivity - safety   (>= 0 means link works)
    r.fibreLoss  = alpha * L;
    r.spliceLoss = nSplice * lSplice;
    r.connLoss   = nConn * lConn;
    r.totalLoss  = r.fibreLoss + r.spliceLoss + r.connLoss;
    r.pRx        = Ptx - r.totalLoss;
    r.margin     = r.pRx - sens - safety;
    r.maxLen     = (Ptx - sens - safety - r.spliceLoss - r.connLoss) / alpha;
end
