function time_series_level_label = MaxEntDist_AllMar_TwoCovFull_Utils_GibbsSampling(x, gray_value_mean_subtracted, N, K, n_sample)
lambda_1 = x(2:N * K + 1); % N is gray level 0 to N-1.
lambda_2 = x(N * K +  2:end); % K variable. first one the variance. from the second one, is the covariance matrix
% construct real gibbs sampling... calculate
% do not be afraid. you are near...
conditional_1_on_other = MaxEntDis_OneMar_TwoCovFull_Utils_CalCondP_Kth_On_Other(1, gray_value_mean_subtracted, lambda_1, lambda_2, N, K);
time_series_level_label = zeros(n_sample, 1);
time_series_level_label(1:K - 1) = randi([1, N], K - 1, 1);
for ii = K:1:n_sample
    previous_condition_assignment = time_series_level_label(ii - 1: -1: ii - (K - 1));
    previous_condition_index = AssignmentToIndex(previous_condition_assignment, ones(K - 1, 1) * N);
    p_this = conditional_1_on_other(:, previous_condition_index);
    time_series_level_label(ii) = GibbsSampling_Utils_OD_Sample(p_this, 1);
end
end