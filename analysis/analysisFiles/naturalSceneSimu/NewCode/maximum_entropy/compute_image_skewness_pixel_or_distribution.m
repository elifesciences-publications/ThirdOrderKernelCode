function [data_pixel, data_distribution] = compute_image_skewness_pixel_or_distribution(x, N)
n_highest_moments = 3;
K = 4;
moments_pixel = zeros(n_highest_moments, 1);
for order = 1:1:n_highest_moments
    moments_pixel(order) = mean(x.^order);
end
% you do not need method one.
[~, ~, ~, ~, ~, moments_distribution] = ...
    MaxEntDis_Utils_Discretize_Contrast_Signal(x, N, K, 'moments_calculation_method', 'discretization_distribution');

%% transfer the moments into variance and skewness
variance_pixel = moments2varskew(moments_pixel, 'variance');
skewness_pixel = moments2varskew(moments_pixel, 'skewness');
data_pixel = [variance_pixel, skewness_pixel];
variance_distribution = moments2varskew(moments_distribution, 'variance');
skewness_distribution = moments2varskew(moments_distribution, 'skewness');
data_distribution = [variance_distribution, skewness_distribution];
end
