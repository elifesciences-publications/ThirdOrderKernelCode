function data = get_statistics_from_p_1(p_1_true, gray_value)
mean_distribution = dot(p_1_true, gray_value);
variance_distribution = variance_p(p_1_true, gray_value);
skewness_distribution = skewness_p(p_1_true, gray_value);
kurtosis_distribution = kurtosis_p(p_1_true, gray_value);
data = [mean_distribution, variance_distribution, skewness_distribution, kurtosis_distribution];
end