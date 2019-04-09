function [x_solved, f_val, solved_flag, time_nonlinear, gray_value, mu_true,  cov_true, correlation_true, resolution_n_pixel,...
    time_series_scale_back_upsample_used, time_series_scale_back_used]=...
    MaxEntDis_ConsMoments_Utils_FromSceneToScene(one_row, varargin)
sample_flag = true;
plot_flag = true;
N = 8;
K = 4;
n_highest_moments = 3;
skewness_fold  = 1;

%% set the spatial correlation to be the mean spatial correlation of all scenes.
set_spatial_correlation_flag = 0;
correlation_true_prefixed = [];
resolution_n_pixel_prefixed = [];
set_fixed_skewness_flag = false;
skewness_prefiexed = [];
solving_method = 'nonlinear_equation';
moments_calculation_method = 'pixel';
symmetrize_flag = false;
lower_bound_flag = false;
auto_thresh = 0.2;
zero_mean_flag = 0;

prefixed_gray_value_flag = false;
prefixed_gray_value = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
n_unknown = 1 + K * n_highest_moments + (K^2 - K)/2;

x_start_initial =  randn(n_unknown, 1) * 0.01;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% should try to have a wider range
%% you can also set mean value to be zero..
[~, gray_value, ~,  correlation_true_individual_scene, resolution_n_pixel_individual_scene, mu_true] ...
    = MaxEntDis_Utils_Discretize_Contrast_Signal(one_row, N, K, 'plot_flag', plot_flag,...
    'n_highest_moments',n_highest_moments, 'skewness_fold', skewness_fold,...
    'set_fixed_skewness_flag', set_fixed_skewness_flag,...
    'skewness_prefiexed',skewness_prefiexed,...
    'moments_calculation_method', moments_calculation_method,...
    'symmetrize_flag', symmetrize_flag,...
    'lower_bound_flag',lower_bound_flag,...
    'auto_thresh',auto_thresh,...
    'zero_mean_flag', zero_mean_flag,...
    'prefixed_gray_value_flag',prefixed_gray_value_flag, ...
    'prefixed_gray_value',prefixed_gray_value);

if  set_spatial_correlation_flag
    correlation_true = correlation_true_prefixed;
    resolution_n_pixel = resolution_n_pixel_prefixed;
else
    correlation_true = correlation_true_individual_scene;
    resolution_n_pixel = resolution_n_pixel_individual_scene;
end
% you have to transfer from correlation to cov_true? yes.
variance_one_variable = mu_true(2) - mu_true(1).^2;
correlation_matrix = zeros( (K^2- K)/2, 1);
for ii = 1:1:K
    for jj = ii + 1:1:K
        ind_this = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj);
        dist_ii_jj = jj - ii;
        correlation_matrix(ind_this) = correlation_true(dist_ii_jj);
    end
end
cov_true = correlation_matrix * variance_one_variable; %% you have to turn this correlation into cov_true with that wiered form.
% cov_true has to be changed into second pairwise moments.
cov_true = cov_true + mu_true(1).^2;

switch solving_method
    case 'nonlinear_equation'
        [x_solved, f_val, solved_flag, time_nonlinear] = MaxEntDis_ConsMoments_Utils_Main...
            (mu_true, cov_true, gray_value, N, K, 'plot_flag', plot_flag,'x_start_initial', x_start_initial,'n_highest_moments',n_highest_moments);
    case 'minimize_potential'
        [x_solved, f_val, solved_flag, time_nonlinear] = MaxEntDis_ConsMoments_MinimizePotential_Utils_Main...
            (mu_true, cov_true, gray_value, N, K, 'plot_flag', plot_flag,'x_start_initial', x_start_initial,'n_highest_moments',n_highest_moments);
end
if sample_flag
    [time_series_scale_back_upsample_used,time_series_scale_back_used]  ...
        = MaxEntDist_ConsMoments_Utils_Sampling_OneScene(x_solved, gray_value, N, K, resolution_n_pixel, 'plot_flag', plot_flag,'n_highest_moments',n_highest_moments);
else
    time_series_scale_back_upsample_used = [];
    time_series_scale_back_used = [];
end
end
