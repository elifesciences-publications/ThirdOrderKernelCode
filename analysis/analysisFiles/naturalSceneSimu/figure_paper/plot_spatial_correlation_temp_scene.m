function plot_spatial_correlation_temp_scene(one_row_this,  color_correlation)
n_autocorr = 50;
%% you should plot three curves, two of them are real spatial correlations, one of them are dots..
n_hor_pixels = 927;
spatial_resolution = 360/n_hor_pixels;
[autocorrelation_this,lags] = autocorr(one_row_this, n_autocorr);
plot(lags *  spatial_resolution, autocorrelation_this, 'color', color_correlation);
end