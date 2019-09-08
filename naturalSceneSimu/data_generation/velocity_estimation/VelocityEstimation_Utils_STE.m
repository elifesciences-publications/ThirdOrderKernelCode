function v2 = VelocityEstimation_Utils_STE(xt_filter, stim_this)
% filtering
sig_right = xt_filter(:,:, 1).*stim_this; sig_right = sum(sig_right(:));
sig_left = xt_filter(:,:, 2).* stim_this; sig_left = sum(sig_left(:));
%% squaring and subtraction
v2 = sig_right^2 - sig_left^2;
end