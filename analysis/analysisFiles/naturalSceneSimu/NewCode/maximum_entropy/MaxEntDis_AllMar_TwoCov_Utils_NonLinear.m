function [F, J] = MaxEntDis_AllMar_TwoCov_Utils_NonLinear(x, p_1_true, cov_true, gray_value_mean_subtracted, DpDx_part1, dFdp, dP2dp, dP1dP2, N, K)

%% first F. .
n_unknows = 1 + N * K + K;
[p_factor, F_est] = MaxEntDis_AllMar_TwoCov_Utils_FromXToPF(x, gray_value_mean_subtracted, dP2dp, dP1dP2, N, K);
% calculate estimate F0, F1, F2.
F = zeros(n_unknows, 1);
F(1) = F_est(1) - 1;
F(2: 1 + N * K) = F_est(2: 1 + N * K) - p_1_true;
F(N * K + 2:end) = F_est(N * K + 2:end)  - cov_true;

% calculate Jacobian
dpdx = bsxfun(@times, DpDx_part1, p_factor.val);
J = dFdp * dpdx;
end
