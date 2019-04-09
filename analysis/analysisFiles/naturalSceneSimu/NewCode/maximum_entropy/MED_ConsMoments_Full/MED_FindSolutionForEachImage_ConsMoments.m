function [med, time_for_each_row, I_syn] = MED_FindSolutionForEachImage_ConsMoments(I, varargin)
n_highest_moments = 3;
plot_flag = false;
sample_flag = false;
skewness_fold = 1;
%% set the spatial correlation to be the mean spatial correlation of all scenes.
set_spatial_correlation_flag = 0;
correlation_true_prefixed = [];
resolution_n_pixel_prefixed = [];
set_fixed_skewness_flag = false;
skewness_prefiexed = [];
solving_method = 'nonlinear_equation';
moments_calculation_method =  'pixel';
use_previous_image_to_seed_flag = 0;
%% you could also choose to set the spatial correlation to be the mean spatial correlation.
N = 8; % this should be able to changed in the future.
K = 4;
n_ver = size(I, 1);
symmetrize_flag = false;
zero_mean_flag = 0;

prefixed_gray_value_flag = 0;
prefixed_gray_value = [];
    
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

med = repmat(struct('solved_flag',false), [n_ver, 1]);
time_for_each_row = cell(n_ver, 1);
if sample_flag
    I_syn = zeros(size(I));
else
    I_syn = [];
end

for rr = 1:1:n_ver
    
    one_row = I(rr, :);
    %% discretize data.
    x_start_initial = randn(K * n_highest_moments +  (K^2 - K)/2 + 1, 1) * 0.01;
    
    if use_previous_image_to_seed_flag && rr ~= 1
        x_start_initial = x_solved;
    end
    
    %% Use this as one scene.
    
    %% also change it such that mean spatial correlation can be used.
    [x_solved, f_val, solved_flag, time_for_each_row{rr}, gray_value, mu_true,  cov_true, correlation_true, resolution_n_pixel, I_syn_this]=...
        MaxEntDis_ConsMoments_Utils_FromSceneToScene(one_row, 'sample_flag', sample_flag, 'plot_flag', plot_flag, 'skewness_fold',skewness_fold,...
        'set_spatial_correlation_flag' ,set_spatial_correlation_flag,...
        'correlation_true_prefixed',correlation_true_prefixed,...
        'resolution_n_pixel_prefixed',resolution_n_pixel_prefixed,...
        'set_fixed_skewness_flag', set_fixed_skewness_flag,...
        'x_start_initial', x_start_initial,...
        'skewness_prefiexed',skewness_prefiexed,'solving_method',solving_method,'moments_calculation_method',moments_calculation_method,...
        'n_highest_moments',n_highest_moments,...
        'symmetrize_flag', symmetrize_flag, 'N', N,'K',K,...
        'lower_bound_flag',lower_bound_flag,...
        'zero_mean_flag',zero_mean_flag,...
        'prefixed_gray_value_flag',prefixed_gray_value_flag,...
        'prefixed_gray_value',prefixed_gray_value);
    %%
    if ~solved_flag
        disp(mu_true);
    end
    %%
    med(rr).gray_value = gray_value;
    med(rr).resolution_n_pixel = resolution_n_pixel;
    med(rr).correlation_true = correlation_true;
    med(rr).cov_true = cov_true;
    med(rr).mu_true = mu_true;
    med(rr).x_solved = x_solved;
    med(rr).N = N;
    med(rr).K = K;
    med(rr).solved_flag = solved_flag;
    med(rr).f_val = f_val;
    %     med(rr).exitflag = exitflag;
    med(rr).time = time_for_each_row{rr};
    
    if sample_flag
        I_syn(rr, :) = I_syn_this;
    end
%     disp(['rr = ', num2str(rr), 'time : ', num2str(mean(time_for_each_row{rr}))]);
end
%% do you want to plot all your solutions.


end
