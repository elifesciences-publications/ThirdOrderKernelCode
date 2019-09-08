function [DpDx, dFdp, dP2dp, dP1dP2] = Calculate_Jacobian_Utils_CommonCoefficient_EveryMarginal(N, K, gray_value_mean_subtracted);
%% for loop.
assignment = IndexToAssignment(1:N^K, ones(K, 1) * N);
DpDx_lambda_0 = ones(N^K, 1);
DpDx_lambda_1 = zeros(N^K, N, K); % There will be a lot of lambda1 and F. N gray level. K marginals.
DpDx_lambda_2 = zeros(N^K, K);

for ii = 1:1:N^K
    assignment_this = assignment(ii, :);
    gray_value_this_mean_subtracted = gray_value_mean_subtracted(assignment_this); % across different variables
    
    % one variable
    for jj = 1:1:K
        DpDx_lambda_1(ii, assignment_this(jj), jj) = 1;
    end
    % two variable
    DpDx_lambda_2(ii,1) = gray_value_this_mean_subtracted' * gray_value_this_mean_subtracted;
    for jj = 2:1:K
        % products
        DpDx_lambda_2(ii,jj) = 2 * gray_value_this_mean_subtracted(1: end - jj + 1)' * gray_value_this_mean_subtracted(jj:end);
    end
    
end
DpDx_lambda_1 = reshape(DpDx_lambda_1, N^K, N*K);
DpDx = [DpDx_lambda_0, DpDx_lambda_1, DpDx_lambda_2];

%%
% on each marginal value, which p(x1...xK) is used?
dP2dp = zeros(N^2, K - 1, N^K); % Different for different dP2
assignment_2 = IndexToAssignment(1:N^2, ones(2, 1) * N);
for ii = 1:1:K-1
    var1 = 1;
    var2 = ii + 1;
    for nn = 1:1:N^2
        ind_this = assignment(:, var1) == assignment_2(nn, 1) & assignment(:, var2) == assignment_2(nn,2);
        dP2dp(nn,ii, :) = ind_this;
    end
end
dP2dp = reshape(dP2dp, N^2 * (K - 1),N^K);
% K one-variable marginals. rely on K-1 two-variable marginals
dP1dP2 = zeros(N, K, N^2, K - 1); % there are K one-variable marginals.  and K - 1 two-variable marginals.E
assignment_1 = 1:N;
jj = 1;
for nn = 1:1:N
    % use first two_varaible marginal
    dP1dP2(nn, jj, :, 1) = assignment_2(:, 1) == assignment_1(nn); % first variable
end

for jj = 2:1:K
    for nn = 1:1:N
        % use first to K-1 two-variable marginals, but average out the
        % first variable.
        dP1dP2(nn, jj, :, jj - 1) = assignment_2(:, 2) == assignment_1(nn); % first variable
    end
end

dP1dP2 = reshape(dP1dP2, N*K, N^2 * (K - 1));
%% dFdP coefficient. % for second
dF_0_dP1 = ones(1, N);
dF_1_dP1 = eye(N*K, N*K);

dF_2_dP1_var = gray_value_mean_subtracted'.^2; % variance
dF_2_dP2_cov = zeros(K - 1, N^2, K - 1); % covariance
gray_value_mean_subtracted_mat = gray_value_mean_subtracted * gray_value_mean_subtracted';
for ii = 1:1:K - 1
    dF_2_dP2_cov(ii,:,ii) = gray_value_mean_subtracted_mat(:);
end
dF_2_dP2_cov = reshape(dF_2_dP2_cov, K - 1, N^2 * (K - 1));
% dFdP = [dF_0_dP1,reshape(dF_0_dP2, 1, N^2 * (K-1));
%         dF_1_dP1,reshape(dF_1_dP2, N, N^2 * (K-1));
%         dF_2_dP1,reshape(dF_2_dP2, K-1, N^2 * (K-1))];

% rely on only one of them.
dF_0_dp = dF_0_dP1 * dP1dP2(1:N, :) * dP2dp; % correct!
dF_1_dp = dF_1_dP1 * dP1dP2 * dP2dp; % correct!
dF_2_dp_var = dF_2_dP1_var * dP1dP2(1:N, :) * dP2dp;
dF_2_dp_cov =  dF_2_dP2_cov * dP2dp;

dFdp = [dF_0_dp; dF_1_dp; dF_2_dp_var; dF_2_dp_cov];
%% calculate Jacobian,

