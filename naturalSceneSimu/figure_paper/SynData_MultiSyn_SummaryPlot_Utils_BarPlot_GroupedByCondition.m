function SynData_MultiSyn_SummaryPlot_Utils_BarPlot_GroupedByCondition(metric, improvement_metric, varargin)
n_condition = length(metric);
x_tick_str = cell(n_condition, 1);
ylabel_str  =[];
order_to_plot = [1,3];

color_bank = [[114, 206, 245]; [49, 168, 73]; [237, 26, 85]]/255;
color_bank = cat(1, color_bank, [0.5,0.5,0.5]);
%
%% you have to create the y axis yourself.
y_axis_value = (1:n_condition) - 0.2;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
n_order = length(order_to_plot);
bar_width = 0.8/n_order;
bar_center_offset = -0.4 - bar_width +  (1:n_order) * bar_width;
%%
% MakeFigure;
% subplot(2,2,3);
hold on
%plot the mean value.
for cc = 1:1:n_condition
    for xx = 1:length(bar_center_offset)
        x_value = bar_center_offset(xx) + y_axis_value(cc);
        ii = order_to_plot(xx);
        mean_value = metric{cc}.mean(ii);
        sem_value = metric{cc}.sem(ii);
        bar(x_value, mean_value, bar_width,'FaceColor',color_bank(ii,:));
        %% plot the sem
        plot([x_value, x_value],[mean_value + sem_value, mean_value - sem_value],'k-');
        %% write the name for conditions
    end
end

yLim = get(gca, 'YLim');
for cc = 1:1:n_condition
    for xx = 1:1:n_order
        x_value = bar_center_offset(xx) + y_axis_value(cc);
        ii = order_to_plot(xx);
        if ii == 1
            text(x_value + 0.1, -0.1, x_tick_str{cc},'Rotation',0,'HorizontalAlignment','center','FontSize',20);
        end
        %% write the improvement
        if ii == 3
            improvement_metric_str = ['(',sprintf('%.1f+/-%.1f', improvement_metric{cc}.mean * 100, improvement_metric{cc}.sem * 100),')%'];
            text(x_value, yLim(2) + 0.1,improvement_metric_str,'Rotation',45,'HorizontalAlignment','center','FontSize', 15)
        end
    end
end
%%
y_min =  min(yLim(1), -0.3);
y_max =  yLim(2)* 1.5;
set(gca,'YLim',[y_min, y_max]);

set(gca, 'XAxisLocation','origin','XTick',[],'YLim',[y_min,y_max]);
ylabel(ylabel_str);
% set(gca,'YLim',[0,0.5]);

ConfAxis
end