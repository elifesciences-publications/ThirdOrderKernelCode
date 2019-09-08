function [DpDx, dFdp, dP2dp, dP1dp] = MaxEntDis_ConsMomements_Utils_Jacobian_Const(N, K, gray_value,  n_highest_moments)
assignment = IndexToAssignment(1:N^K, ones(K, 1) * N);
%% 
DpDx_lambda_0 = ones(N^K, 1);
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

DpDx = [DpDx_lambda_0, DpDx_lambda_1_variable, DpDx_lambda_2_variable];

%% df over probability.
%  (K^2 - K)/2 two-variable marginals.
dP2dp = zeros(N^2, (K^2 - K)/2, N^K); % Different for different dP2. only upper part is used, not including the diagonal lines.
assignment_2 = IndexToAssignment(1:N^2, ones(2, 1) * N);
for var1 = 1:1:K
    for var2 = var1 + 1:1:K
        ind_in_dP2dp = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(var1, var2);
        for nn = 1:1:N^2
            ind_this = assignment(:, var1) == assignment_2(nn, 1) & assignment(:, var2) == assignment_2(nn,2);
            dP2dp(nn,ind_in_dP2dp, :) = ind_this;
        end
    end
    
end
dP2dp = reshape(dP2dp, N^2 * (K^2 - K)/2, N^K);

% K one-variable marginals.
dP1dp = zeros(N, K, N^K);
assignment_1 = 1:N;
for ii = 1:1:K
    for nn = 1:1:N
        ind_this = assignment(:, ii) == assignment_1(nn);
        dP1dp(nn,ii, :) = ind_this;
    end
end
dP1dp = reshape(dP1dp, N*K, N^K);

%% dFdP coefficient. has to be changed.

dF_0_dp = ones(1, N^K);
dF_1_variable_dp = zeros(K, n_highest_moments, N^K);
dF_2_variable_dp = zeros((K^2 - K)/2, N^K);
for order = 1:1:n_highest_moments
    dF_1_variable_dp(1:K, order, :) = (gray_value(assignment).^order)';
end
dF_1_variable_dp = reshape(dF_1_variable_dp, [K*n_highest_moments, N^K]);

for jj = 2:1:K
    for ii = 1:jj - 1
        ind = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj);
        dF_2_variable_dp(ind, :) = gray_value(assignment(:, ii)) .* gray_value(assignment(:, jj));
    end
end

dFdp = [dF_0_dp; dF_1_variable_dp; dF_2_variable_dp];
%% calculate Jacobian,

