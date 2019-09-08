function [logF, J_logF] = MaxEntDis_ConsMoments_Utils_CalculatePotential(lambda, mu_true, gray_value, cov_true, n_highest_moments, N, K, DpDx_part1)
%% lambda does not have lambda_0 compare to the nonlinear equation version.
% lambda_marginal = zeros(K, n_highest_moments); 

if K == 1
    fake_lambda_0 = 1 - (lambda(1: K * n_highest_moments)' * mu_true);
else
    lambda_covaraince = lambda(K * n_highest_moments + 1:end);
    fake_lambda_0 = 1 - (lambda(1: K * n_highest_moments)' * mu_true + dot(lambda_covaraince,cov_true));
end
% calculate the covariance true
%% reuse original function. 
p_joint = MaxEntDis_ConsMoments_Utils_FromLambdaToP([fake_lambda_0; lambda], gray_value, N, K,'n_highest_moments',n_highest_moments);
F = sum(p_joint(:));
logF = log(F);
%% Jacobian should not be very hard. Friday, finish this.
dpdx = bsxfun(@times, DpDx_part1, p_joint);
J = sum(dpdx);
J_logF = J./F;
end



