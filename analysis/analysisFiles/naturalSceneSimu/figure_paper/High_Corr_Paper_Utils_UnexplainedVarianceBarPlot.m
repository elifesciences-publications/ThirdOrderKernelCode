function High_Corr_Paper_Utils_UnexplainedVarianceBarPlot(r_plot, color_bank, fontsize_label)

unexplained_variance = 1- r_plot.^2;
improvement_metric = (unexplained_variance(1) - unexplained_variance(3))./ unexplained_variance(1) * 100;

for ii = 1:1:4
    hold on
    bar(ii, unexplained_variance(ii),'FaceColor',color_bank(ii, :),'EdgeColor',[0 0 0])
end

box off
yLim = get(gca, 'YLim');
xLim = get(gca, 'XLim');
set(gca, 'XAxisLocation','origin');
set(gca, 'XTick',[]);
% set(gca, 'YTick',[-.5])
% instead using xtick, use text.
x_tick_str = {'2nd ','3rd','2nd + 3rd','weighted 2nd and 3rd'};
for ii = 1:1:length(x_tick_str)
    text(ii, -0.3, x_tick_str{ii},'Rotation',45,'HorizontalAlignment','center','FontSize',fontsize_label);
end
yl = ylabel('unexplained variance','FontSize',fontsize_label);
hold on
plot([0,5],[unexplained_variance(1), unexplained_variance(1)],'k--');

improvement_metric_str = [sprintf('%.0f%', improvement_metric),'%'];
text(3, yLim(2) + 0.1,improvement_metric_str,'Rotation',45,'HorizontalAlignment','center','FontSize', 15)
y_max = max(1, max(unexplained_variance));
y_min = min(-0.2, min(unexplained_variance));

set(gca,'YLim',[0, y_max]);
ConfAxis
end
