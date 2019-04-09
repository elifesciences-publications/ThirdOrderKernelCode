function [time_series_upsample_used, time_series_used, time_series]  = MaxEntDist_ConsMoments_Utils_Sampling_OneScene(x_solved_scale, gray_value, N, K, resolution_n_pixel, varargin)
n_hor = 927;
n_times = 1;
n_sample = 10000;
plot_flag = false;
n_highest_moments = 3;
sampling_method = 'sequential';
interp1_method = [];
upsampling_method = 'resample';
seed = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% time_series_level_label = ...
%     MaxEntDist_AllMar_TwoCov_Utils_GibbsSampling(x_solved_scale, gray_value_mean_subtracted_scale, N, K, n_sample);
if K == 1
    time_series_level_label = ...
        MaxEntDist_ConsMoments_PixelDist_Utils_Sampling_TimeSeriesLevel(x_solved_scale, gray_value, N, K, n_sample,'n_highest_moments',n_highest_moments);
else
    switch sampling_method
        case 'sequential'
            time_series_level_label = ...
                MaxEntDist_ConsMoments_Utils_Sampling_TimeSeriesLevel(x_solved_scale, gray_value, N, K, n_sample,'n_highest_moments',n_highest_moments);
        case 'random'
            time_series_level_label  = MaxEntDist_Utils_Sampling_TimeSeriesLevel_RandomUpdate(x_solved_scale, gray_value, N, K, n_sample,'n_highest_moments',n_highest_moments);
            
    end
end
time_series = gray_value(time_series_level_label);
if plot_flag
    MaxEntDis_Utils_Gibbs_Utils_PlotOneTimeSeries(time_series, gray_value,N,K);
end
n_sample_used = ceil(n_hor * n_times/resolution_n_pixel);
time_series_used = time_series(end - n_sample_used + 1 :  end);

switch upsampling_method
    case 'resample'
        time_series_upsample_used = resample(time_series_used , resolution_n_pixel, 1);
    case 'interp1'
        time_series_used = time_series(end - n_sample_used:  end);
        t_down = 1:resolution_n_pixel:length(time_series_used) * resolution_n_pixel;
        t_up = 1:(length(time_series_used) - 1) * resolution_n_pixel;
        time_series_upsample_used = interp1( t_down, time_series_used, t_up, interp1_method);
        time_series_upsample_used = time_series_upsample_used(:);
end
time_series_upsample_used = time_series_upsample_used(1:n_hor * n_times)'; % turn it into row vector.
%% you should have a plotting function here to judge the distribution extra.
end
