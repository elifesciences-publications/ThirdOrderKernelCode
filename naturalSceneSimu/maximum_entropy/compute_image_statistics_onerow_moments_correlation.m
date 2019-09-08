function  data = compute_image_statistics_onerow_moments_correlation(x, varargin)

N = 8;
K = 4;
med = [];
prefixed_discretization_flag = false;
upsample_flag = true;
symmetrize_flag = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% get all data possible
n_highest_moments = 3;
if prefixed_discretization_flag
    prefixed_gray_value_flag = true;
    prefixed_gray_value = med.gray_value;
    prefixed_resolution_n_pixel_flag = true;
    if upsample_flag
        prefixed_resolution_n_pixel = med.resolution_n_pixel;
    else
        prefixed_resolution_n_pixel = 1;
    end
    x_downsample = x(1:prefixed_resolution_n_pixel:end);
    N = length(prefixed_gray_value);
    [~, gray_value,  p_1_true, correlation_true, ~,~] = ...
        MaxEntDis_Utils_Discretize_Contrast_Signal(x_downsample, N, K, 'moments_calculation_method', 'discretization_distribution',...
        'n_highest_moments',n_highest_moments,'prefixed_gray_value_flag',prefixed_gray_value_flag,'prefixed_gray_value',prefixed_gray_value,...
        'prefixed_resolution_n_pixel_flag', prefixed_resolution_n_pixel_flag,'prefixed_resolution_n_pixel',1,'symmetrize_flag',symmetrize_flag,...
        'zero_mean_flag',zero_mean_flag,'lower_bound_flag',lower_bound_flag);
else
    [~, gray_value,  p_1_true, correlation_true, ~,~] = ...
        MaxEntDis_Utils_Discretize_Contrast_Signal(x, N, K, 'moments_calculation_method', 'discretization_distribution',...
        'n_highest_moments',n_highest_moments,'symmetrize_flag',symmetrize_flag,'zero_mean_flag',zero_mean_flag,'lower_bound_flag',lower_bound_flag);
    
end
mean_distribution = dot(p_1_true, gray_value);
variance_distribution = variance_p(p_1_true, gray_value);
skewness_distribution = skewness_p(p_1_true, gray_value);
kurtosis_distribution = kurtosis_p(p_1_true, gray_value);

data = [mean_distribution; variance_distribution; skewness_distribution; kurtosis_distribution; correlation_true];
end
