function  data = compute_solution_statistics_onerow_moments_correlation(med, n_highest_moments)
%% get all data possible
N = med.N;
K = med.K;
gray_value = med.gray_value; gray_value = reshape(gray_value, length(gray_value), 1);
x_solved = med.x_solved;
[~, ~, p_i, correlation_solved] = MaxEntDis_ConsMoments_Utils_PlotResult(x_solved, gray_value, [], [], n_highest_moments, N, K,'plot_flag',false);
%% There are four variables. do the mean value? probabily.... okay...
p_1 = mean(p_i,2);
mean_distribution = dot(p_1, gray_value);
variance_distribution = variance_p(p_1, gray_value);
skewness_distribution = skewness_p(p_1, gray_value);
kurtosis_distribution = kurtosis_p(p_1, gray_value);

data = [mean_distribution;variance_distribution;skewness_distribution;kurtosis_distribution;correlation_solved];
end
