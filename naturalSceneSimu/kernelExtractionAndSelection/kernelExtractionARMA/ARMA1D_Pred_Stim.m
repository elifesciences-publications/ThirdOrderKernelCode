function r = ARMA1D_Pred_Stim(s,ks)
% given stimulus, real response, and kernels(1st order).
% all the analysis you could do about LN model

% for the first order kernel, what is the filter's ability on predicting
% response? including the r?
nT = length(s);
r = zeros(nT,1);

rks = filter(ks,1,s);

% only consider the ability of the stimulus to explaine the data..
r = rks;

end