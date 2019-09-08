function SynData_MultiSyn_SummaryPlot_Utils_BarPlot_GroupedByOrder(metric, improvement_metric, varargin)
n_condition = length(metric);
x_tick_str = cell(n_condition, 1);
ylabel_str  =[];
% x_tick_str = {'natural scene ','-2','-1','-0.5','0','0.5','1','2'};

color_bank = [[114, 206, 245]; [49, 168, 73]; [237, 26, 85]]/255;
color_bank = cat(1, color_bank, [0.5,0.5,0.5]);
%%
weight_ratio = [];
%% you have to create the y axis yourself.
y_axis_value = 1:4;
bar_width = 0.6/n_condition;
bar_center_offset = -0.3 - bar_width/2 +  (1:n_condition) * bar_width;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%%
MakeFigure;
hold on
%plot the mean value.
for cc = 1:1:n_condition
    for ii = 1:1:length(metric{cc}.mean)
        
        x_value = bar_center_offset(cc) + y_axis_value(ii);
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
    for ii = 1:1:length(metric{cc}.mean)
         x_value = bar_center_offset(cc) + y_axis_value(ii);
        if ii == 1
            text(x_value, -0.15, x_tick_str{cc},'Rotation',45,'HorizontalAlignment','center','FontSize',14);
        end
        %% write the improvement
        if ii == 3
            improvement_metric_str = ['(',sprintf('%.1f+/-%.1f', improvement_metric{cc}.mean * 100, improvement_metric{cc}.sem * 100),')%'];
            text(x_value, yLim(2) + 0.1,improvement_metric_str,'Rotation',45,'HorizontalAlignment','center','FontSize', 15)
        end
        
        if ii == 4 && ~isempty(weight_ratio) 
            % write the best weight.
            weight_ratio_str = ['(',sprintf('%.1f+/-%.1f', weight_ratio{cc}.mean, weight_ratio{cc}.sem),')'];
            text(x_value, yLim(2) + 0.1,weight_ratio_str,'Rotation',45,'HorizontalAlignment','center','FontSize', 15)
        end
    end
end

% y_min =  min(yLim(1), 0);
y_min = -0.3;
y_max =  yLim(2)* 1.5;
set(gca,'YLim',[y_min, y_max]);
ConfAxis

set(gca, 'XAxisLocation','origin','XTick',[],'YLim',[y_min,y_max]);
ylabel(ylabel_str);

%% label for each context
ConfAxis
end