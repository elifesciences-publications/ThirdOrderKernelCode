function [time_series_scale_back_upsample_used,solved_flag, gray_value_edge, gray_value, resolution_n_pixel] = MaxEndDis_Utils_FromNS_To_SynS(one_row, varargin)
plot_flag = false;
n_hor  = length(one_row); n_times = 1;
n_sample = 5000; % 10000 might be too much
N = 8; % this should be able to changed in the future.
K = 4;
n_unknows = 1 + N*K + (K^2 + K)/2 ;
x_start_initial = rand(n_unknows, 1) * 0.1;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
%% discretize data.
[gray_value_edge, gray_value, p_1_true,  correlation_true, resolution_n_pixel] = MaxEntDis_Utils_Discretize_Contrast_Signal(one_row, N, K, 'plot_flag', plot_flag);

%% It is cool you got the correlation.
[x_solved_scale, gray_value_mean_subtracted_scale, solved_flag] =...
    MaxEntDis_Utils_FindDist_To_MatchUp_GrayLevel_Correlation_FullC(gray_value, correlation_true, p_1_true, N, K,'plot_flag',plot_flag,'x_start_initial',x_start_initial);
%%
if solved_flag
[time_series_scale_back_upsample_used,time_series_scale_back_used]  = ...
    MaxEntDist_AllMar_TwoCovFull_Utils_GibbsSampling_OneScene(x_solved_scale, gray_value_mean_subtracted_scale, gray_value, N, K, resolution_n_pixel,'plot_flag',true);
else
    time_series_scale_back_upsample_used = [];
end
% time_series_level_label = ...
%     MaxEntDist_AllMar_TwoCov_Utils_GibbsSampling(x_solved_scale, gray_value_mean_subtracted_scale, N, K, n_sample);
% time_series_scale_back = gray_value(time_series_level_label);
% 
% n_sample_used = ceil(n_hor * n_times/resolution_n_pixel);
% time_series_scale_back_used = time_series_scale_back(end - n_sample_used + 1 :  end);
% time_series_scale_back_upsample_used = resample(time_series_scale_back_used , resolution_n_pixel, 1);
% time_series_scale_back_upsample_used = time_series_scale_back_upsample_used(1:n_hor * n_times)'; % turn it into row vector.

%% the periodic condition is not satisfied...

if plot_flag
    MaxEntDis_Utils_Gibbs_Utils_PlotOneTimeSeries(time_series_scale_back_used, gray_value,N,K);
    MaxEntDis_Utils_Gibbs_Utils_PlotOrignalSceneAndNewScene(one_row, time_series_scale_back_upsample_used, gray_value_edge)
end
%% you might want to upsampling it.
% 
% MakeFigure; 
% subplot(2,1,1);
% MaxEntDis_Utils_Discretize_Contrast_Signal(time_series_scale_back_upsample_used, N, K, 'plot_flag', true);
% MaxEntDis_Utils_Discretize_Contrast_Signal(one_row, N, K, 'plot_flag', true);

end
