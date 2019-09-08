function [assignment, sum_two_variable, sum_one_variable] = ...
    MaxEntDis_AllMar_TwoCovFull_Utils_LambdaToSum(var_name, lambda_one_variable, lambda_two_variable, gray_values_mean_subtracted, N, K)

K_ = length(var_name); 
lambda_one_variable_mat = reshape(lambda_one_variable, N, K);

%% lambda_tow_variable. The First K are the variance. From the K - 1, are the covariance? Is it true? not sure. 


covariance_matrix_from_lambda = zeros(K, K);
% you need ii jj to ind.
[ind_ii,ind_jj] = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Ind2Sub(1:(K^2 - K)/2);
for kk = 1:1:K
    covariance_matrix_from_lambda(kk,kk) = lambda_two_variable(kk); % first K variance
end
for kk = 1:1:(K^2 - K)/2
    covariance_matrix_from_lambda(ind_ii(kk), ind_jj(kk)) = lambda_two_variable(kk + K); % Other's are just zeros.
end


covariance_matrix_from_lambda_ = covariance_matrix_from_lambda(var_name, var_name);

lambda_one_variable_mat = lambda_one_variable_mat(:, var_name);lambda_one_variable_mat = lambda_one_variable_mat';
% 
assignment = IndexToAssignment(1: N^K_, ones(K_, 1) * N);
sum_two_variable = zeros(N^K_, 1);
sum_one_variable = zeros(N^K_, 1);

for nn = 1:1:N^K_
    % optimize this in the future.
    mean_subtracted_variable_vec = gray_values_mean_subtracted(assignment(nn,:));
    sum_two_variable(nn) = mean_subtracted_variable_vec' * covariance_matrix_from_lambda_ * mean_subtracted_variable_vec;
    sum_one_variable(nn) = sum(lambda_one_variable_mat(sub2ind([K_,N], 1:K_, assignment(nn,:))));
end


end
