function natural_scene_histogram_temp(stim_scene,gray_value, color_this, varargin)
n_gray = 8;
plot_statistics_flag = 1;
symmetrize_flag = 0;
zero_mean_flag = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
color_distribution = color_this;
color_mean = color_this;
color_skew = color_this;

FontSize = 15;
h_kde = 0.075;
contrast_max = max(abs(stim_scene));
%% plot the distribution

% gray_value = linspace(-contrast_max, contrast_max, N + 1); % That is a great idea actuall... you should do 11 levels.
% what if you do not use h_hist_value?
gray_vlaue_edge = [-contrast_max - 3; (gray_value(2:end)+gray_value(1:end-1))/2; contrast_max + 3];
h_hist_value = histcounts(stim_scene, gray_vlaue_edge);
% h_hist_value = kde_juyue_contrast_plotting(stim_scene , gray_value,
% h_kde); do not use the smoothed version.
h_hist_value = h_hist_value./sum(h_hist_value);

semilogy(gray_value, h_hist_value, 'color', color_distribution); hold on;
set(gca, 'XLim', [-contrast_max,contrast_max]);
% set(gca, 'XLim', [-5,5]);

ylim_max = 1;
set(gca, 'YLim',[0.5 * 1e-3,ylim_max]);
set(gca,'YTick',[0.01,0.1,1],'YTickLabel',{'0.01','0.1','1'});
ylim  = get(gca, 'YLim');

%% use the other one...
[~, gray_value, p_1_true,  ~, ~, mu_true] ...
    = MaxEntDis_Utils_Discretize_Contrast_Signal(stim_scene, n_gray, 1,...
    'n_highest_moments',3, 'skewness_fold', 1,...
    'moments_calculation_method', 'discretization_distribution','symmetrize_flag', symmetrize_flag,'zero_mean_flag',zero_mean_flag);

variance_value = moments2varskew(mu_true, 'variance');

%% get the contrast
mean_contrast = dot(p_1_true, gray_value);
std_contrast = variance_p(p_1_true, gray_value);
skewness_contrast = skewness_p(p_1_true, gray_value);
kurtosis_contrast = kurtosis_p(p_1_true, gray_value);
%% plot mean and variance
if plot_statistics_flag
    h_mean = scatter(mean_contrast,ylim_max,20, 'k','filled');
    % plot([mean_contrast - std_contrast, mean_contrast + std_contrast], [sqrt(ylim(2)/ylim(1)),sqrt(ylim(2)/ylim(1))] * ylim(1), 'color',color_mean);
    h_std = plot([mean_contrast - std_contrast, mean_contrast + std_contrast], [ylim_max, ylim_max], 'color',color_mean);
    h_mean.Annotation.LegendInformation.IconDisplayStyle = 'off';
    h_std.Annotation.LegendInformation.IconDisplayStyle = 'off';
    %% plot the skewness
    skew_text_skew = text(1.5, 1, sprintf('skewness = %0.2f', skewness_contrast),'color', color_skew, 'FontSize', FontSize);
    skew_text_skew.Color = color_skew;
    skew_text_skew.FontSize = FontSize;
    
    % %% also plot the
    % skew_text_kurt = text(contrast_max * 0.2, 0.001, sprintf('kurtosis = %0.2f', kurtosis_contrast),'color', color_skew, 'FontSize', FontSize);
    % skew_text_kurt.Color = color_skew;
    % skew_text_kurt.FontSize = FontSize;
end
ConfAxis

% title('contrast distribution');
% xlabel('contrast');
% ylabel('relative probability')
%
end