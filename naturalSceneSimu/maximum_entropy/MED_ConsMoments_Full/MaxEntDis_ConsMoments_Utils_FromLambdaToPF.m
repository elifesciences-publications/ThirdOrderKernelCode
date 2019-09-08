function [p_joint, F_est] = MaxEntDis_ConsMoments_Utils_FromLambdaToPF(lambda, gray_value, dP2dp, dP1dp, n_highest_moments, N, K)
%% first, calculate the probability
p_joint = MaxEntDis_ConsMoments_Utils_FromLambdaToP(lambda, gray_value, N, K);

%% second, calculate the one/two-variable distribution
p_ij = dP2dp * p_joint; p_ij = reshape(p_ij, [N^2, (K^2-K)/2]);
p_i = dP1dp * p_joint; p_i = reshape(p_i, [N, K]);
%% third, calculate the F_est. Turn this into a function as well
F_est = MaxEntDis_ConsMoments_Utils_FromMargiPtoF(p_ij, p_i, gray_value, n_highest_moments, N, K);
end

%% alternative way to compuate p_ij and p_i. much slower.
% can you make this step faster??
% tic
% dP2dp = reshape(dP2dp, N^2, (K^2-K)/2, N^K);
% p_ij = repmat(struct('val',[],'var',[],'card', ones(K, 1)*N), (K^2-K)/2, 1);
% for ii = 1:1:K
%     for jj = ii + 1:1:K
%         ind_this = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj );
%         p_ij(ind_this).var = [ii, jj];
%         for nn = 1:1:N^2
%             p_ij(ind_this).val(nn) = sum(p_joint(dP2dp(nn,ind_this,:) == 1)); % should be faster than marginalization.
%         end
%     end
% end
% toc
% do not have to do this.
% calculate the one-variable marginal
% p_i  = repmat(struct('var', [],'card',N, 'val', zeros(N, 1)), K, 1);
% dP1dp = reshape(dP1dp, N, K, N^K); %Do you want to use dP1dp directly?
% for ii = 1:1:K
%     p_i(ii).var = ii;
%     for nn = 1:1:N
%         p_i(ii).val(nn) = sum(p_joint(dP1dp(nn, ii, :) == 1));
%     end
% end