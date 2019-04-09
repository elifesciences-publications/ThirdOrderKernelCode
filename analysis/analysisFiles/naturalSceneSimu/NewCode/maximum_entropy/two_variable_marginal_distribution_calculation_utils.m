function [assignment, sum_two_variable, sum_one_variable] = ...
    two_variable_marginal_distribution_calculation_utils(var_name, lambda_one_variable, lambda_two_variable, gray_values_mean_subtracted, N, K)

K_ = length(var_name); 
lambda_one_variable_mat = reshape(lambda_one_variable, N, K);

cov_mat_value_ind_in_lambda_two_variable = covariance_index_transition_mat_to_vector(1:K^2, K);
covariance_matrix_from_lambda = reshape(lambda_two_variable(cov_mat_value_ind_in_lambda_two_variable), K, K);
covariance_matrix_from_lambda_ = covariance_matrix_from_lambda(var_name, var_name);

lambda_one_variable_mat = lambda_one_variable_mat(:, var_name);
% 
assignment = IndexToAssignment(1: N^K_, ones(K_, 1) * N);
sum_two_variable = zeros(N^K_, 1);
sum_one_variable = zeros(N^K_, 1);

for ii = 1:1:N^K_
    % optimize this in the future.
    mean_subtracted_variable_vec = gray_values_mean_subtracted(assignment(ii,:));
    sum_two_variable(ii) = mean_subtracted_variable_vec' * covariance_matrix_from_lambda_ * mean_subtracted_variable_vec;
    
    lambda_one_variable_mat(sub2ind([N, K_], 1:K_, assignment(ii,:)));
    sum_one_variable(ii) = sum(lambda_one_variable(assignment(ii,:)));
end


end

    
    
%     A = false(N,K_);
%     A(sub2ind([N,K_],assignment(ii,:), 1:K_)) = true;

%     sum_one_variable(ii) = sum(lambda_one_variable' * A);
% write down possible combinations
% hist_count_assign = zeros(N^K, 3);
% for ii = 1:1:N^K_
%      a = accumarray(assignment(ii,:)',1);
%      hist_count_assign(ii, 1:length(a)) = a;
% end