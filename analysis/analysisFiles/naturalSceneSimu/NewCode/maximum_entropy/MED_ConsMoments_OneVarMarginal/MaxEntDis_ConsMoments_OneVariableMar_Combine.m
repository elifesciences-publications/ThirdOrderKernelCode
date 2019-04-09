function data = MaxEntDis_ConsMoments_OneVariableMar_Combine(mu_true, correlation_true, resolution_n_pixel, gray_value, K, varargin)

plot_flag = false;
N = length(gray_value);
n_unknows = 1 + N*K + (K^2 + K)/2 ;
x_start_initial = rand(n_unknows, 1) * 0.01;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% try to fit a distribution with different probability distribution.
n_highest_moments = length(mu_true);
[x_solved_one_variable] = MaxEntDis_ConsMoments_OneVaribleMar_Main(mu_true, n_highest_moments, gray_value, N);
[mu_solved, p_1_true] = MaxEntDis_ConsMoments_OneVaribleMar_Utils_FromXToMoments(x_solved_one_variable, gray_value, N);
[x_solved_scale, gray_value_mean_subtracted_scale, solved_flag,~,  ~, ~,...
    x_solved_scale_back, gray_value_mean_subtracted] =...
    MaxEntDis_Utils_FindDist_To_MatchUp_GrayLevel_Correlation_FullC(gray_value, correlation_true, p_1_true, N, K,'plot_flag',false,'x_start_initial',x_start_initial);

%% write a new plotting function.
% give it a try.
if plot_flag
    mu_true_all = repmat(mu_true, [1, K])';
    mu_est = repmat(mu_solved(2:end), [1, K])'; 
    MaxEntDis_ConsMoments_OneVariableMar_PlotResult(x_solved_scale_back, gray_value_mean_subtracted, gray_value, ...
        mu_true_all(:), mu_est, correlation_true, n_highest_moments, N, K);
end
%% you should plot it.

[time_series_scale_back_upsample_used,time_series_scale_back_used]  = ...
    MaxEntDist_AllMar_TwoCovFull_Utils_GibbsSampling_OneScene...
    (x_solved_scale, gray_value_mean_subtracted_scale, gray_value, N, K, resolution_n_pixel,'plot_flag',false);

data.scene = time_series_scale_back_upsample_used;
data.solved_flag = solved_flag;
data.x_solved_scale = x_solved_scale;
data.gray_value_mean_subtrasted_scale = gray_value_mean_subtracted_scale;
data.gray_value = gray_value;
data.resolution_n_pixel = resolution_n_pixel;
end