function [p_factor, F_est] = MaxEntDis_AllMar_TwoCov_Utils_FromXToPF(x, gray_value_mean_subtracted, dP2dp, dP1dP2, N, K)
n_unknows = 1 + N * K + K;
% decompose unknowns into meaningful lambda.
p_factor = MaxEntDis_AllMar_TwoCov_Utils_LambdaToP(x, gray_value_mean_subtracted, N,K);
%% calculate all two-variable marginals
marginal_distribution_2_variable = struct('var', zeros(2, 1),'card',[N, N], 'val', zeros(N^2, 1));
p_ij = repmat(marginal_distribution_2_variable, K-1, 1);
dP2dp = reshape(dP2dp, N^2, K-1, N^K);
for ii = 1:1:K - 1
    p_ij(ii).var = [1, ii + 1];
    for nn = 1:1:N^2
        p_ij(ii).val(nn) = sum(p_factor.val(dP2dp(nn,ii,:) == 1)); % should be faster than marginalization.
        find(squeeze(dP2dp(nn,ii,:)));
    end
    %   p_ij(ii) = FactorMarginalization(p_factor, find(~ismember(1:K, [1, ii + 1])));
end

%% calculate the one-variable marginal
% pi_test = FactorMarginalization(p_ij(1), 2);
p_i  = repmat(struct('var', [],'card',N, 'val', zeros(N, 1)), K, 1);
dP1dP2 = reshape(dP1dP2, N, K, N^2, (K - 1)); %Do you want to use dP1dp directly?
for ii = 1:1:K
    p_i(ii).var = ii;
    for nn = 1:1:N
        if ii == 1
            p_i(ii).val(nn) = sum(p_ij(1).val(squeeze(dP1dP2(nn,1,:, 1)) == 1));
        else
            p_i(ii).val(nn) = sum(p_ij(ii - 1).val(squeeze(dP1dP2(nn,ii,:,ii - 1)) == 1));
        end
    end
end

%% sum to 1.
sum_p = sum(p_i(1).val);

%%
F_est = zeros(n_unknows, 1);
F_est(1) = sum_p;
F_est(2: 1 +  N*K ) = cat(1, p_i(:).val);

C_11 = p_i(1).val' * (gray_value_mean_subtracted.^2);
cov_between_variables = zeros(K - 1, 1);
for ii = 1:1:K - 1
    cov_between_variables(ii) = gray_value_mean_subtracted' * reshape(p_ij(ii).val, [N,N]) * gray_value_mean_subtracted;
end
F_est(N*K + 2:end) = [C_11; cov_between_variables];

end