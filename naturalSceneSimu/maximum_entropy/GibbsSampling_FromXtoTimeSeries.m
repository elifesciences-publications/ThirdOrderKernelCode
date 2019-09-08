function time_series = GibbsSampling_FromXtoTimeSeries(x, N, K)
% lambda_0 = x(1);
lambda_1 = x(2:N * K + 1); % N is gray level 0 to N-1.
lambda_2 = x(N * K +  2:end); % K variable. first one the variance. from the second one, is the covariance matrix
% first, get the conditional distribution
conditional_1_on_other = MaxEntDis_OneMar_TwoCov_Utils_CalCondP_Kth_On_Other(1, gray_value_mean_subtracted, lambda_1, lambda_2, N,K);
time_series_level_label(1:K - 1) = randi([1, N], K - 1, 1);

for ii = K:1:n_sample
    previous_condition_assignment = time_series_level_label(ii - 1: -1: ii - (K - 1));
    previous_condition_index = AssignmentToIndex(previous_condition_assignment, ones(K - 1, 1) * N);
    p_this = conditional_1_on_other(:, previous_condition_index);
    time_series_level_label(ii) = GibbsSampling_Utils_OD_Sample(p_this, 1);
end
% change the level_label into values.
time_series = gray_value(time_series_level_label);
end
% test the statistics of these time series. first,
% MakeFigure;plot(time_series_level_label)
% MakeFigure;
% subplot(2,2,1)
% histogram(time_series_level_label,[0.5:1:N+0.5]);
% subplot(2,2,2);
% bar(p_1_true(1:N));
% subplot(2,2,3);
% bar(p_1.val);
% subplot(2,2,4)
% autocorr(time_series)