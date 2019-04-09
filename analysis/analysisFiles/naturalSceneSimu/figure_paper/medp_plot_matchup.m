function h = medp_plot_matchup(gray_value, p_i, color_this,plot_statistics_flag, color_skew)

color_distribution = color_this;
color_mean =[0,0,0];
% color_skew = [0,0,0];

FontSize = 15;
contrast_max = max(abs(gray_value));
%% plot the distribution

h = semilogy(gray_value, p_i/sum(p_i), 'color', color_distribution); hold on;
set(gca, 'XLim', [-contrast_max,contrast_max]);
% set(gca, 'XLim', [-1,4]);


% set(gca, 'YLim',[0.5 * 1e-3,ylim_max]);
% set(gca,'YTick',[0.01,0.1,1],'YTickLabel',{'0.01','0.1','1'});
set(gca, 'YLim', [0, 0.2],'YScale','linear');
set(gca,'YTick',[0,0.1,0.2],'YTickLabel',{'0','0.1','0.2'});
ylim_max = 0.2;

ylim  = get(gca, 'YLim');

%% calculate the thing here..
mean_contrast = p_i' * gray_value;
std_contrast = sqrt(variance_p(p_i, gray_value));
skewness_contrast = skewness_p(p_i, gray_value);
%% compute kurtosis... not that easy... how?
kurtosis_contrast = kurtosis_p(p_i, gray_value);
%%
if plot_statistics_flag
    h_mean = scatter(mean_contrast,ylim_max,20,'filled','MarkerEdgeColor', color_mean,'MarkerFaceColor', color_mean);
    % plot([mean_contrast - std_contrast, mean_contrast + std_contrast], [sqrt(ylim(2)/ylim(1)),sqrt(ylim(2)/ylim(1))] * ylim(1), 'color',color_mean);
    h_std =plot([mean_contrast - std_contrast, mean_contrast + std_contrast], [ylim_max, ylim_max], 'color',color_mean);
    %     h_mean.Annotation
    h_mean.Annotation.LegendInformation.IconDisplayStyle = 'off';
    h_std.Annotation.LegendInformation.IconDisplayStyle = 'off';
    %% plot the skewness
    skew_text = text(-3, ylim_max, sprintf('skewness = %0.2f', skewness_contrast),'color', color_skew, 'FontSize', FontSize);
    skew_text.Color = color_skew;
    skew_text.FontSize = FontSize;
    % %
    % skew_text_kurt = text(contrast_max * 0.6, 0.001, sprintf('kurtosis = %0.2f', kurtosis_contrast),'color', color_skew, 'FontSize', FontSize);
    % skew_text_kurt.Color = color_skew;
    % skew_text_kurt.FontSize = FontSize;
end
ylabel('log(probability)');
ConfAxis

% title('contrast distribution');
% xlabel('contrast');
% ylabel('relative probability')
%
end