function [DpDx, dFdp, dP2dp, dP1dp] = Calculate_Jacobian_Utils_CommonCoefficient_EveryMarginalCov(N, K, gray_value_mean_subtracted);
%% for loop.
assignment = IndexToAssignment(1:N^K, ones(K, 1) * N);
DpDx_lambda_0 = ones(N^K, 1);
DpDx_lambda_1 = zeros(N^K, N, K); % There will be a lot of lambda1 and F. N gray level. K marginals.
% DpDx_lambda_2_temp = zeros(N^K, K,K); % only assign first half of it...
DpDx_lambda_2 = zeros(N^K, (K^2 - K)/2 + K); % first K are variance. Later on.
%%
for nn = 1:1:N^K
    assignment_this = assignment(nn, :);
    gray_value_this_mean_subtracted = gray_value_mean_subtracted(assignment_this); % across different variables
    
    % one variable
    for jj = 1:1:K
        DpDx_lambda_1(nn, assignment_this(jj), jj) = 1;
    end
    
    % two variable
    for ii = 1:1:K
        DpDx_lambda_2(nn,ii) = gray_value_this_mean_subtracted(ii).^2; % first K values. in lambda2 is lambda for variance.
        % later on is lambda for covariance.
        for jj = ii + 1:1:K
            DpDx_lambda_2(nn, K + Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj)) = gray_value_this_mean_subtracted(ii) * gray_value_this_mean_subtracted(jj);
        end
    end
end
DpDx_lambda_1 = reshape(DpDx_lambda_1, N^K, N*K);
DpDx = [DpDx_lambda_0, DpDx_lambda_1, DpDx_lambda_2];

%%
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
%% dFdP coefficient. 
dF_0_dP1 = ones(1, N);
dF_1_dP1 = eye(N*K, N*K);

%% dF_2 on marginal distribution.
dF_2_dP1_var = zeros(K, N, K); % There are N*K terms in one-variable marginal.
dF_2_dP2_cov = zeros((K^2 - K)/2, N^2, (K^2 - K)/2); 
% first, calculate dF_2_var_dP1. variance terms.
for ii = 1:1:K
    dF_2_dP1_var(ii, :, ii) = gray_value_mean_subtracted'.^2;
end
dF_2_dP1_var = reshape(dF_2_dP1_var, K, N*K);
for ii = 1:1:K
    for jj = ii + 1:1:K
        % find out the ind
        ind_in_dP2dp = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj);
        gray_value_mean_subtracted_mat = gray_value_mean_subtracted * gray_value_mean_subtracted'; % you can take only the first half. 
        dF_2_dP2_cov(ind_in_dP2dp, :, ind_in_dP2dp)  = gray_value_mean_subtracted_mat(:);
    end
end
dF_2_dP2_cov = reshape(dF_2_dP2_cov, (K^2 - K)/2, N^2 * (K^2 - K)/2);
%%
% rely on only one of them.
dF_0_dp = dF_0_dP1 * dP1dp(1:N, :); % correct!
dF_1_dp = dF_1_dP1 * dP1dp; % correct!
dF_2_dp_var = dF_2_dP1_var * dP1dp;
dF_2_dp_cov =  dF_2_dP2_cov * dP2dp;

dFdp = [dF_0_dp; dF_1_dp; dF_2_dp_var; dF_2_dp_cov];
