function r = ARMA2D_Pred(stim1,stim2,ks,kr)
% given stimulus, real response, and kernels(1st order amd 2nd order).
% all the analysis you could do about LN model

% for the first order kernel, what is the filter's ability on predicting
% response? including the r?
maxTau_ks = length(ks(:));
maxTau_kr = length(kr);
maxTau = round(sqrt(maxTau_ks));
ks = reshape(ks,[maxTau,maxTau]);

nT = length(stim1);

rks = zeros(nT,1);
for ii = 1:(nT)-(maxTau-1)
    rks(ii+(maxTau-1)) = flipud(stim1(ii:ii+maxTau-1))'*ks*flipud(stim2(ii:ii+maxTau-1));
end

r = zeros(nT,1);
for tt = maxTau_kr + 1:1:nT
    rkr = kr * r(tt-1:-1:tt - maxTau_kr);
    r(tt) = rkr + rks(tt);
end

end