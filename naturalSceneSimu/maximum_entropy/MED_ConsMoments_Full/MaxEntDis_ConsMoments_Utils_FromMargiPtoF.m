function F_est = MaxEntDis_ConsMoments_Utils_FromMargiPtoF(p_ij, p_i, gray_value, n_highest_moments, N, K)
F_0_est = sum(p_i(:, 1));
% calculate the moments for each individual.
mu_est = zeros(K, n_highest_moments);
for order = 1:1:n_highest_moments
    for ii = 1:1:K
        mu_est(ii, order) = moment_computing(p_i(:, ii), gray_value, order);
    end
end
mu_est = mu_est(:);
cov_est = zeros((K^2 - K)/2, 1);
for ii = 1:1:(K^2 - K)/2
    cov_est(ii) = gray_value' * reshape(p_ij(:, ii), [N,N]) * gray_value;
end
F_est = [F_0_est; mu_est; cov_est];
end