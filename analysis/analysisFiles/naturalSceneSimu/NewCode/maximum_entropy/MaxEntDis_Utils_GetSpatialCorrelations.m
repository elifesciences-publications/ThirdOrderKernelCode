function [correlation_true, resolution_n_pixel] = MaxEntDis_Utils_GetSpatialCorrelations(x, K, varargin)
auto_thresh = 0.2;
prefixed_resolution_n_pixel_flag = false;
prefixed_resolution_n_pixel = [];

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
[acf, lags] = autocorr(x, min([100, length(x) - 1]));
range_of_correlation = min([find(diff(find(acf > auto_thresh))~=1), max(find(acf > auto_thresh))]); % 20 pixel not really 0.2..
if ~prefixed_resolution_n_pixel_flag
    resolution_n_pixel = floor((range_of_correlation - 1)/(K - 1));
else
    resolution_n_pixel = prefixed_resolution_n_pixel;
end
% determine the sampling resolution. half size is 0.7, 0,5, 0.3.
lag_ind = find(ismember(lags,resolution_n_pixel:resolution_n_pixel: resolution_n_pixel * (K - 1)));
correlation_true = acf(lag_ind)';
end