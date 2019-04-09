function [p_factor, F_est] = MaxEntDis_AllMar_TwoCovFull_Utils_FromXToPF(x, gray_value_mean_subtracted, dP2dp, dP1dp, N, K)
n_unknows = 1 + N * K + (K^2 + K)/2;
% decompose unknowns into meaningful lambda.
p_factor = MaxEntDis_AllMar_TwoCovFull_Utils_LambdaToP(x, gray_value_mean_subtracted, N,K);
%% calculate all two-variable marginals
marginal_distribution_2_variable = struct('var', zeros(2, 1),'card',[N, N], 'val', zeros(N^2, 1));
p_ij = repmat(marginal_distribution_2_variable, (K^2-K)/2, 1);
dP2dp = reshape(dP2dp, N^2, (K^2-K)/2, N^K);
for ii = 1:1:K
    for jj = ii + 1:1:K
        ind_this = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj );
        p_ij(ind_this).var = [ii, jj];
        for nn = 1:1:N^2
            p_ij(ind_this).val(nn) = sum(p_factor.val(dP2dp(nn,ind_this,:) == 1)); % should be faster than marginalization.
        end
    end
end
%% test correct by marginalization.
% p_ij_test = repmat(marginal_distribution_2_variable, (K^2-K)/2, 1);
% for ii = 1:1:K
%     for jj = ii + 1:1:K
%         ind_this = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj );
%         
%         p_ij_test(ind_this)= FactorMarginalization(p_factor, find(~ismember(1:K, [ii, jj])));
%         isequal(p_ij_test(ind_this).val, p_ij(ind_this).val)
%     end
% end



%% calculate the one-variable marginal
% pi_test = FactorMarginalization(p_ij(1), 2);
p_i  = repmat(struct('var', [],'card',N, 'val', zeros(N, 1)), K, 1);
dP1dp = reshape(dP1dp, N, K, N^K); %Do you want to use dP1dp directly?
for ii = 1:1:K
    p_i(ii).var = ii;
    for nn = 1:1:N
        p_i(ii).val(nn) = sum(p_factor.val(dP1dp(nn, ii, :) == 1));
    end
end
%% test correct by marginalization.
% p_i_test =  repmat(struct('var', [],'card',N, 'val', zeros(N, 1)), K, 1);
% for ii = 1:1:K
%     p_i_test(ii) = FactorMarginalization(p_factor, find(~ismember(1:K, ii)));
%     isequal(p_i_test(ii).val, p_i(ii).val);
% end

%% sum to 1.
sum_p = sum(p_i(1).val);

%%
F_est = zeros(n_unknows, 1);
F_est(1) = sum_p;
F_est(2: 1 +  N*K ) = cat(1, p_i(:).val);

%% variance
F_variance = zeros(K, 1);
for ii = 1:1:K
    % calculate covariance.
    F_variance(ii) =  p_i(ii).val' * gray_value_mean_subtracted.^2;
end
%% covariance
F_covariance = zeros((K^2 - K)/2, 1);
for ii = 1:1:(K^2 - K)/2
    F_covariance(ii) = gray_value_mean_subtracted' * reshape(p_ij(ii).val, [N,N]) * gray_value_mean_subtracted;
end


F_est(N*K + 2:end) = [F_variance; F_covariance];


end