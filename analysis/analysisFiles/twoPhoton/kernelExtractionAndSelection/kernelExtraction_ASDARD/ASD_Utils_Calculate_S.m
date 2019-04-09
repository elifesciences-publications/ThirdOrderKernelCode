function S = ASD_Utils_Calculate_S(rho,distMatT,distMatS,smoothT,smoothS)
    S = exp(-rho - 1/2 * (distMatT/smoothT.^2 + distMatS/smoothS.^2));
end