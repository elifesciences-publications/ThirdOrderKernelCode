function[gray_value_edge, gray_value, p_1_true,  correlation_true, resolution_n_pixel, moments] = MaxEntDis_Utils_Discretize_Contrast_Signal(x, N, K, varargin)
plot_flag = false;
auto_thresh = 0.2;
n_highest_moments = 3;
skewness_fold = 1; % default value is 1.
set_fixed_skewness_flag = false;
skewness_prefiexed = [];
moments_calculation_method = 'pixel';
prefixed_gray_value_flag = false;
prefixed_gray_value = [];
prefixed_resolution_n_pixel_flag = false;
prefixed_resolution_n_pixel = [];
symmetrize_flag = 0;
zero_mean_flag = 0;
lower_bound_flag = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
%% This is poor programming...
if ~prefixed_gray_value_flag
    if symmetrize_flag
        if zero_mean_flag
            center_x = 0;
        else
            center_x = mean(x);
        end
        max_range = max(abs(x));
        gray_value_edge = linspace(center_x - max_range, center_x + max_range, N + 1);
    elseif lower_bound_flag
        gray_value_edge = linspace(-1, max(x), N + 1); % lower bounded... how about set a fixed gray_value? how much you can hit?
    else
        gray_value_edge = linspace(min(x), max(x), N + 1); % That is a great idea actuall... you should do 11 levels.
    end
else
    if N == length(prefixed_gray_value)
        edge_middle = (prefixed_gray_value(1:end - 1) + prefixed_gray_value(2:end))/2;
        edge_middle = reshape(edge_middle, 1, N - 1);
        left_edge = min(min(x), edge_middle(1) - mean(diff(prefixed_gray_value))/2);
        right_edge = max(max(x) + 1e-5, edge_middle(end) + mean(diff(prefixed_gray_value))/2);
        gray_value_edge = [left_edge, edge_middle, right_edge];
    else
        error('length of (prefixed gray value) is not the same as N');
    end
end
[counts, ~] = histcounts(x, gray_value_edge);
if ~prefixed_gray_value_flag
    gray_value = (gray_value_edge(1:end - 1) + gray_value_edge(2:end))/2; gray_value = gray_value';
else
    gray_value = reshape(prefixed_gray_value, length(prefixed_gray_value), 1);
end
p_1_true = counts'/length(x); % not probability density, but probability.
% calculate the correlation between nearby point.
%
% [acf, lags] = autocorr(x, min([100, length(x) - 1]));
% range_of_correlation = min([find(diff(find(acf > auto_thresh))~=1), max(find(acf > auto_thresh))]); % 20 pixel not really 0.2..
% if ~prefixed_resolution_n_pixel_flag
%     resolution_n_pixel = floor((range_of_correlation - 1)/(K - 1));
% else
%     resolution_n_pixel = prefixed_resolution_n_pixel;
% end
% % determine the sampling resolution. half size is 0.7, 0,5, 0.3.
% lag_ind = find(ismember(lags,resolution_n_pixel:resolution_n_pixel: resolution_n_pixel * (K - 1)));
% correlation_true = acf(lag_ind)';
if K == 1
    [correlation_true, resolution_n_pixel] = MaxEntDis_Utils_GetSpatialCorrelations(x, 2,...
        'prefixed_resolution_n_pixel_flag',prefixed_resolution_n_pixel_flag,...
        'prefixed_resolution_n_pixel',prefixed_resolution_n_pixel,...
        'auto_thresh',auto_thresh);
else
    [correlation_true, resolution_n_pixel] = MaxEntDis_Utils_GetSpatialCorrelations(x, K,...
        'prefixed_resolution_n_pixel_flag',prefixed_resolution_n_pixel_flag,...
        'prefixed_resolution_n_pixel',prefixed_resolution_n_pixel,...
        'auto_thresh',auto_thresh);
end
%% calculate moments of the example.
moments = zeros(n_highest_moments, 1);
switch moments_calculation_method
    case 'pixel'
        for order = 1:1:n_highest_moments
            moments(order) = mean(x.^order);
        end
    case 'discretization_distribution'
        for order = 1:1:n_highest_moments
            moments(order) = dot(p_1_true, gray_value.^order);
        end
end
%% adjust the third order moments.
if zero_mean_flag
     mean_value = 0;
else
    mean_value  = moments2varskew(moments, 'mean');
end
variance_value = moments2varskew(moments, 'variance');
if n_highest_moments == 3
    skewness_value = moments2varskew(moments, 'skewness');
    skewness_adjustment = skewness_value * skewness_fold;
    
    if set_fixed_skewness_flag
        skewness_adjustment = skewness_prefiexed;
    end
    moments = varskew2moments(mean_value , variance_value, skewness_adjustment);
else
    moments = varskew2moments(mean_value , variance_value,0 );
    moments(3) = [];
end

%%
if plot_flag
    MakeFigure;
    subplot(3,1,1);
    plot(x);
    title('natural scene');
    ConfAxis
    
    subplot(3,2,3);
    h_hist = histogram(x, gray_value_edge, 'Normalization', 'probability'); hold on;
    h_hist.FaceColor = [0,0,0];
    %     plot(gray_value, p_1_true,'r');
    title('contrast distribution');
    ConfAxis
    
    subplot(3,2,4);
    n_hor_pixels = 927;
    n_autocorr= 100;
    [autocorrelation_this,lags] = autocorr(x, n_autocorr);
    spatial_resolution = 360/n_hor_pixels;
    plot(lags *  spatial_resolution, autocorrelation_this,'r');
    hold on
    hold on; plot(get(gca, 'XLim'), [0,0],'k--');
    xlabel('\delta x [degree]');
    title('spatial correlation');
    hold on
    for ii = 1:1:K - 1
        scatter(lags(lag_ind(ii)) * spatial_resolution, correlation_true(ii),'k','filled');
    end
    ConfAxis
    
    
end
end