function [sig_corr, sig_var, sig_max_xcorr, corr_offset] = movie_analysis_sig(x)
nT = size(x, 3);

% cum_mean = zeros(size(x));
% cum_mean(:,:,1) = x(:,:,1);
% for tt = 2:1:nT
%     cum_mean(:,:,tt) = cum_mean(:,:,tt - 1) * (tt - 1)/tt + x(:,:,tt)/tt;
% end

%% 
sig_corr = zeros(nT, 1);
sig_max_xcorr = zeros(nT, 1);

sig_var = zeros(nT, 1);
corr_offset = zeros(nT, 2);
for tt = 2:1:nT % later and before.
    a = x(:,:,tt-1);
    b = x(:,:,tt);
    sig_corr(tt) = corr(a(:),b(:));
    sig_var(tt) = var(b(:));
    
    c = xcorr2(a - mean(a), b - mean(b));
    [val, idx] = max(abs(c(:)));
    [ypeak, xpeak] = ind2sub(size(c), idx);
    corr_offset(tt, :) = [(ypeak-size(x,1)) (xpeak-size(x,2))];
    sig_max_xcorr(tt) = val/numel(x);
end

%%
sig_corr(1) = nan;
b = x(:,:,1);
sig_var(1) = var(b(:));
sig_max_xcorr(1) = nan;
end