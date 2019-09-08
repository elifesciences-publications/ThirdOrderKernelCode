function  conditional_p = MaxEntDis_OneMar_TwoCovFull_Utils_CalCondP_Kth_On_Other(var_x, gray_value_mean_subtracted, lambda_1, lambda_2, N,K)
% compute the conditional probability. p_x_conditioned_on_y
assignment = IndexToAssignment(1:N^(K - 1), ones(K - 1, 1) * N);
conditional_p = zeros(N, N^(K - 1));

covariance_matrix_from_lambda = zeros(K, K);
% you need ii jj to ind.
[ind_ii,ind_jj] = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Ind2Sub(1:(K^2 - K)/2);
for kk = 1:1:K
    covariance_matrix_from_lambda(kk,kk) = lambda_2(kk); % first K variance
end
for kk = 1:1:(K^2 - K)/2
    covariance_matrix_from_lambda(ind_ii(kk), ind_jj(kk)) = lambda_2(kk + K); % Other's are just zeros.
end


covariance_matrix_cross_over = covariance_matrix_from_lambda(var_x, :)';
covariance_matrix_cross_over(var_x) = [];
% covariance_matrix_cross_over = lambda_2(end:-1:2); % correlation between K and 1, 2, 3, ..., K-1.
lambda_1_mat = reshape(lambda_1, N, K);
lambda_1_var_x = lambda_1_mat(:, var_x);
for nn = 1:1:N^(K - 1) % if first K-1th variable are known.
    
    % only this variable, and cross_over needs to be considered
    assignment_this = assignment(nn, :);
    
    sum_one_variable = lambda_1_var_x;
    sum_two_variable_cross_over =  gray_value_mean_subtracted(assignment_this)'* covariance_matrix_cross_over * gray_value_mean_subtracted(1: N);
    sum_two_variable_self = gray_value_mean_subtracted(1: N) * covariance_matrix_from_lambda(var_x, var_x) .* gray_value_mean_subtracted(1: N);
    p = exp(sum_one_variable + sum_two_variable_self +  sum_two_variable_cross_over);
    conditional_p(:, nn) = p./sum(p);
end
end

% 
% conditional_x1_x2x3_using_p_factor = zeros(size(conditional_x3_x1x2));
% assignment_full = IndexToAssignment(1:N^K, ones(K, 1) * N);
% assignment = IndexToAssignment(1:N^(K - 1), ones(K - 1, 1) * N);
% % how could you compute this? all evidence where the
% for ii = 1:1:N^(K - 1)
%     p_observation = false(N^K, K - 1);
%     
%     for jj = 1:1:K - 1
%         p_observation(assignment_full(:, jj) == assignment(ii,jj), jj) = true;
%     end
%     p = p_factor.val(prod(p_observation, 2) == 1);
%     conditional_x3_x1x2_using_p_factor(:,ii) = p./sum(p);
% end