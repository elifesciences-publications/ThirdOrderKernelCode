function MaxEntDis_ConsMoments_OneVariableMar_PlotResult(x_solved_scale_back, gray_value_mean_subtracted, gray_value, mu_true, mu_est, correlation_true, n_highest_moments, N, K)
%% calculate a lot of things and call plot function 
% first, call the old function.
[p_ij_struct, p_i_struct, covariance_matrix_solved] = MaxEntDis_Utils_FullCov_SolveNonLinear_Utils_PlotResult(x_solved_scale_back, gray_value_mean_subtracted, N,K, 'plot_flag', false);
% first, turn structure into matrix.
p_ij = zeros(N^2, (K^2-K)/2);
for kk = 1:1:(K^2-K)/2
        p_ij(:, kk) = p_ij_struct(kk).val;
end
p_i = zeros(N, K);
for kk = 1:1:K
    p_i(:, kk) = p_i_struct(kk).val;
end

cov_true = correlation_true * covariance_matrix_solved(1, 1);
cov_est = zeros((K^2-K)/2, 1);
for kk = 1:1:(K^2-K)/2
    [ii, jj] = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Ind2Sub(kk);
    cov_est(kk) =  covariance_matrix_solved(ii, jj);
end
% do transition here. 
MaxEntDis_ConsMoments_Utils_PlotResult_Plot(gray_value, p_i, p_ij, mu_true, mu_est, cov_true, cov_est, covariance_matrix_solved,n_highest_moments, N, K)

% several different input argument.
end