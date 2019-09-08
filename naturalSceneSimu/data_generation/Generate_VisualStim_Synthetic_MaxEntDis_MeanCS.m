function time_series_scale_back_upsample_used = Generate_VisualStim_Synthetic_MaxEntDis_MeanCS(img_distribution)
med = img_distribution;
% gray_value_edge = med.gray_value_edge;
% p_1_true = med.p_1_true;
% correlation_true = med.correlation_true;
gray_value = med.gray_value;
resolution_n_pixel = med.resolution_n_pixel;
x_solved_scale = med.x_solved_scale;
gray_value_mean_subtracted_scale = med.gray_value_mean_subtracted_scale;
N = med.N;
K = med.K;

[time_series_scale_back_upsample_used,~]  = MaxEntDist_AllMar_TwoCov_Utils_GibbsSampling_OneScene(x_solved_scale, gray_value_mean_subtracted_scale, gray_value, N, K, resolution_n_pixel);

end