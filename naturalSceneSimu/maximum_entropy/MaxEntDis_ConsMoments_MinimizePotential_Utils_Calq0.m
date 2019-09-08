function x_solve_nonlinear_equation_format = MaxEntDis_ConsMoments_MinimizePotential_Utils_Calq0(x_solved, K, N, n_highest_moments, mu_true, cov_true,gray_value)
% lambda_marginal = zeros(K, n_highest_moments);
lambda_marginal = x_solved(1: K * n_highest_moments);
lambda_marginal = reshape(lambda_marginal, K, n_highest_moments);
lambda_covaraince = x_solved(K * n_highest_moments + 1:end);
if K == 1
    x_solve_tmp = [1 - (sum(lambda_marginal * mu_true)); x_solved];
else
    x_solve_tmp = [1 - (sum(lambda_marginal * mu_true) + lambda_covaraince' * cov_true); x_solved];
end
% calculate the covariance true
p_joint = MaxEntDis_ConsMoments_Utils_FromLambdaToP(x_solve_tmp, gray_value, N, K,'n_highest_moments',n_highest_moments);
q0 = -log(sum(p_joint));

if K == 1
    lambda_0 = q0  + 1 - (sum(lambda_marginal * mu_true));
else
    lambda_0 = q0  + 1 - (sum(lambda_marginal * mu_true) + lambda_covaraince' * cov_true);
end
x_solve_nonlinear_equation_format = [lambda_0; x_solved];

% p_joint_new = MaxEntDis_ConsMoments_Utils_FromLambdaToP(x_solve_nonlinear_equation_format, gray_value, N, K);

end