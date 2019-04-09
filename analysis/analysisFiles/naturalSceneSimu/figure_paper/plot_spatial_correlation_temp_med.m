function plot_spatial_correlation_temp_med(resolution_n_pixel, correlation_true, color_correlation_matched, K)
%% you should plot three curves, two of them are real spatial correlations, one of them are dots..
n_hor_pixels = 927;
n_autocorr = 50;
lags = 0:n_autocorr;
spatial_resolution = 360/n_hor_pixels;

lag_ind = find(ismember(lags,resolution_n_pixel:resolution_n_pixel: resolution_n_pixel * (K - 1)));
for kk = 1:1:K - 1
    scatter(lags(lag_ind(kk)) * spatial_resolution, correlation_true(kk), 'filled','MarkerFaceColor',color_correlation_matched);
end
end