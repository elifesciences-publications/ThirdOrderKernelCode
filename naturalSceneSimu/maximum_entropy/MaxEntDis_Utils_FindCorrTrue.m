function [correlation_true, resolution_n_pixel]  = MaxEntDis_Utils_FindCorrTrue(acf, auto_thresh, K)
lags = 0:(length(acf) - 1);
range_of_correlation = min([find(diff(find(acf > auto_thresh))~=1), max(find(acf > auto_thresh))]); % 20 pixel not really 0.2..
resolution_n_pixel = floor((range_of_correlation - 1)/(K - 1));

lag_ind = find(ismember(lags,resolution_n_pixel:resolution_n_pixel: resolution_n_pixel * (K - 1)));
correlation_true = acf(lag_ind)';
end