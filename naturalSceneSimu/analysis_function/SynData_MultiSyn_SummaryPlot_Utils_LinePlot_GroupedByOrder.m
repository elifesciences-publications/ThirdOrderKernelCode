function SynData_MultiSyn_SummaryPlot_Utils_LinePlot_GroupedByOrder(metric, varargin)
n_condition = length(metric);
x_tick_str = cell(n_condition, 1);
ylabel_str  =[];
x_tick = [];
x_value = [];
% x_tick_str = {'natural scene ','-2','-1','-0.5','0','0.5','1','2'};

color_bank = [[114, 206, 245]; [49, 168, 73]; [237, 26, 85]]/255;
color_bank = cat(1, color_bank, [0.5,0.5,0.5]);
%%
weight_ratio = [];
%% you have to create the y axis yourself.
y_axis_value = 1:4;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
if isempty(x_value)
     x_value = 1:n_condition;
end
%%
for ii = 1:1:3
    mean_value  = zeros(n_condition, 1);
    sem_value = zeros(n_condition, 1);
    for cc = 1:1:n_condition
        mean_value(cc) = metric{cc}.mean(ii);
        sem_value(cc) = metric{cc}.sem(ii);
        %% plot the sem
        plot([x_value(cc), x_value(cc)],[mean_value(cc) + sem_value(cc), mean_value(cc) - sem_value(cc)],'k-');
        %% write the name for conditions
    end
    plot(x_value, mean_value,'.-', 'color',color_bank(ii,:));
end

yLim = get(gca, 'YLim');
% y_min =  min(yLim(1), 0);
y_min = -0.3;
y_max =  yLim(2) * 1.1;
set(gca,'YLim',[y_min, y_max]);
if isempty(x_tick)
    x_tick = 1:n_condition;
end
set(gca, 'XTick', x_tick, 'XTickLabel',x_tick_str);
ylabel(ylabel_str);
xlabel(xlabel_str);
%% label for each context
end