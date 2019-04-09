function High_Corr_Paper_Utils_CorrelationBarPlot(r_plot, color_bank, fontsize_label)
improvement_metric = (r_plot(3) - r_plot(1))/r_plot(1)  * 100;

for ii = 1:1:4
    hold on
    bar(ii, r_plot(ii),'FaceColor',color_bank(ii, :),'EdgeColor',[0 0 0])
end

box off
yLim = get(gca, 'YLim');
xLim = get(gca, 'XLim');
set(gca, 'XAxisLocation','origin');
set(gca, 'XTick',[]);

% instead using xtick, use text.
x_tick_str = {'2nd ','3rd','2nd + 3rd','weighted 2nd and 3rd'};
for ii = 1:1:length(x_tick_str)
    text(ii, yLim(1), x_tick_str{ii},'Rotation',45,'HorizontalAlignment','center','FontSize',fontsize_label);
end
yl = ylabel('correlation with image velocity','FontSize',fontsize_label);
hold on
plot([0,5],[r_plot(1), r_plot(1)],'k--');



improvement_metric_str = [sprintf('%.0f%', improvement_metric),'%'];
text(3, yLim(2) + 0.1,improvement_metric_str,'Rotation',45,'HorizontalAlignment','center','FontSize', 15)
y_max= max(0.7, max(r_plot));
y_min = min(-0.2, min(r_plot));

set(gca,'YLim',[y_min, y_max]);
ConfAxis
end
