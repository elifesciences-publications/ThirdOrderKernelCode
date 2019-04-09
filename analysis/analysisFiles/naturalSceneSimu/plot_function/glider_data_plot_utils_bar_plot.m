function glider_data_plot_utils_bar_plot(glider_resp_3o_mean, glider_resp_3o_sem, glider_resp_3o_p,h, lineWidth)
% axes('Units', h.Units, 'Position',h.Position);
n_type_glider = size(glider_resp_3o_mean, 1);

bar_axes = bar((1:n_type_glider)', glider_resp_3o_mean ,'EdgeColor',[0 0 0],'LineWidth', lineWidth);
bar_axes(1).BarWidth = 1;
bar_axes(1).FaceColor = [1 1 1];
bar_axes(2).FaceColor = [0 0 0];
yLimMax = max(glider_resp_3o_mean(:)) * 1.2;
glider_data_plot_utils_bar_plot_utils_sigPoint((1:n_type_glider)', glider_resp_3o_p, yLimMax);
hold on
glider_data_plot_utils_bar_plot_utils_error_bar((1:n_type_glider)',  glider_resp_3o_mean, glider_resp_3o_sem);

set(gca, 'XTick',[]);
ylabel('turning response [degree/second]');

set(gca, 'YLim', [-yLimMax, yLimMax]);
box off
set(gca, 'XAxisLocation','origin');
High_Corr_PaperFig_Utils_SmallFontSize
% determine the width of each bar, the width of each axis...
end

% barPlot = bar((1:n_type_glider * 2)', glider_resp_3o_mean_bar(:) ,'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
% PlotError_SigPoint_Juyue((1:n_type_glider * 2)', glider_resp_3o_p(:), yLimMax)
% PlotErrorBar_Juyue((1:n_type_glider * 2)',  glider_resp_3o_mean(:), glider_resp_3o_sem(:));
% instead of writing, 
% set(gca, 'XTick', 1:1:n_type_glider * 2, 'XtickLabel', glider_str_3o);
% set(gca, 'XTick', 1:1:n_type_glider * 2, 'XtickLabel', []);

% yLim = get(gca,'YLim');
% yLimMax = max(abs(yLim));