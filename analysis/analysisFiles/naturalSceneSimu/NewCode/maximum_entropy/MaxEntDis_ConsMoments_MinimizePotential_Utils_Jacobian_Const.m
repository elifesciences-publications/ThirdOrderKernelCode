function [DpDx] = MaxEntDis_ConsMoments_MinimizePotential_Utils_Jacobian_Const(N, K, gray_value, mu_true, cov_true, n_highest_moments)
assignment = IndexToAssignment(1:N^K, ones(K, 1) * N);
%%
DpDx_lambda_1_variable = zeros(N^K, K,  n_highest_moments); %
DpDx_lambda_2_variable = zeros(N^K, (K^2 - K)/2); % first K are variance. Later on.

for order = 1:1:n_highest_moments
    DpDx_lambda_1_variable(1:N^K, 1:K, order) = gray_value(assignment).^order;
end
DpDx_lambda_1_variable = reshape(DpDx_lambda_1_variable, [N^K, K * n_highest_moments]);

%% To compute covariance matrix, you have to use mean subtracted gray_value.
for jj = 2:1:K
    for ii = 1:jj - 1
        ind = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj);
        DpDx_lambda_2_variable(:, ind) = gray_value(assignment(:, ii)) .* gray_value(assignment(:, jj));
    end
end
% if K == 1
%     DpDx = [DpDx_lambda_1_variable - mu_true'];
% else
    DpDx = [DpDx_lambda_1_variable - mu_true', DpDx_lambda_2_variable - cov_true'];
end
