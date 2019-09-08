function r = ARMA1D_Pred(s,ks,kr)
% given stimulus, real response, and kernels(1st order).
% all the analysis you could do about LN model

% for the first order kernel, what is the filter's ability on predicting
% response? including the r?
maxTau_kr = length(kr);

nT = length(s);
r = zeros(nT,1);

rks = filter(ks,1,s);
for tt = maxTau_kr + 1:1:nT
    rk2 = kr * r(tt-1:-1:tt - maxTau_kr);
    r(tt) = rk2 + rks(tt);
end

end