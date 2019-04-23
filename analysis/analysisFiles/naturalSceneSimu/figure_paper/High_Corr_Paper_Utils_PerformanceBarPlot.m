function High_Corr_Paper_Utils_PerformanceBarPlot(metric, improvement_metric,color_bank, fontsize_label, y_label_str, varargin)
axesFontSize = 10;
% unexplained_variance = 1- r_plot.^2;
% improvement_metric = (unexplained_variance(1) - unexplained_variance(3))./ unexplained_variance(1) * 100;
x_tick_str = {'2nd ','3rd','2nd + 3rd','weighted 2nd and 3rd'};
weight_ratio = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
n_bar = length(metric.mean);

for ii = 1:1:n_bar 
    hold on
    bar(ii, metric.mean(ii),'FaceColor',color_bank(ii, :),'EdgeColor',[0 0 0])
end
if isfield(metric,'sem')
    for ii = 1:1:n_bar 
        plot([ii,ii], [metric.mean(ii) + metric.sem(ii),  metric.mean(ii) - metric.sem(ii)], 'k-');
    end
end

box off
yLim = get(gca, 'YLim');
xLim = get(gca, 'XLim');
set(gca, 'XAxisLocation','origin');
set(gca, 'XTick',[]);
% set(gca, 'YTick',[-.5])

for ii = 1:1:length(x_tick_str)
    text(ii, -0.3, x_tick_str{ii},'Rotation',45,'HorizontalAlignment','center','FontSize',fontsize_label);
end

yl = ylabel(y_label_str,'FontSize',fontsize_label);

hold on
plot([0,5],[metric.mean(1),metric.mean(1)],'k--');

if isfield(metric,'sem')
    % same precision.
    improvement_metric_str = ['(',sprintf('%.1f+/-%.1f', improvement_metric.mean * 100, improvement_metric.sem * 100),')%'];
else
    improvement_metric_str = [sprintf('%.1f%', improvement_metric.mean * 100),'%'];
end
text(3, yLim(2) + 0.1,improvement_metric_str,'Rotation',45,'HorizontalAlignment','center','FontSize', axesFontSize)

% if ~isempty(weight_ratio)
%     weight_ratio_str = ['(',sprintf('%.1f+/-%.1f', weight_ratio.mean, weight_ratio.sem ),')'];
%     text(n_bar, yLim(2) + 0.1,weight_ratio_str,'Rotation',45,'HorizontalAlignment','center','FontSize', axesFontSize)
% end

y_max =  max(metric.mean)* 1.5;
y_min =  min(min(metric.mean)* 1.5, 0);

set(gca,'YLim',[y_min, y_max]);
end
