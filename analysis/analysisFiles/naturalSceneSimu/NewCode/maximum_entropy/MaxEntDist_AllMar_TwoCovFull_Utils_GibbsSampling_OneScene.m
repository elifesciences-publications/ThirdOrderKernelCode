function [time_series_scale_back_upsample_used,time_series_scale_back_used]  = MaxEntDist_AllMar_TwoCovFull_Utils_GibbsSampling_OneScene(x_solved_scale, gray_value_mean_subtracted_scale, gray_value, N, K, resolution_n_pixel, varargin)
n_hor = 927;
n_times= 1;
n_sample = 10000;
plot_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% time_series_level_label = ...
%     MaxEntDist_AllMar_TwoCov_Utils_GibbsSampling(x_solved_scale, gray_value_mean_subtracted_scale, N, K, n_sample);
time_series_level_label = ...
    MaxEntDist_AllMar_TwoCovFull_Utils_GibbsSampling(x_solved_scale, gray_value_mean_subtracted_scale, N, K, n_sample);

time_series_scale_back = gray_value(time_series_level_label);
if plot_flag
    MaxEntDis_Utils_Gibbs_Utils_PlotOneTimeSeries(time_series_scale_back, gray_value,N,K);
end

n_sample_used = ceil(n_hor * n_times/resolution_n_pixel);
time_series_scale_back_used = time_series_scale_back(end - n_sample_used + 1 :  end);
time_series_scale_back_upsample_used = resample(time_series_scale_back_used , resolution_n_pixel, 1);
time_series_scale_back_upsample_used = time_series_scale_back_upsample_used(1:n_hor * n_times)'; % turn it into row vector.


%% you should have a plotting function here to judge the distribution extra.
end
