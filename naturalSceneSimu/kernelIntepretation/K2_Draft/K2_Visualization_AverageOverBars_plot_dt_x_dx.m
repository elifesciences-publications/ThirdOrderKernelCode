function K2_Visualization_AverageOverBars_plot_dt_x_dx(dt_x_dx_plot_average_over_bar, varargin)
title_main_name  = [];
dt_bank = [-8:8];
x_bank = [8:13];
n_average_over_bars = 2; % could be three.
dx_plot = 0;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
n_bar_show = size(dt_x_dx_plot_average_over_bar,2);
x_bank = x_bank(1:n_bar_show);
% you have to decide whether this is a significant test.
quickViewOneKernel(dt_x_dx_plot_average_over_bar,1,'labelFlag',false);

title([title_main_name,' dx = ', num2str(dx_plot), ' av ', num2str(n_average_over_bars)],'FontSize',30);

%% xlabel
ylabel('dt');
xlabel('bar #');
set(gca, 'YTick',1:length(dt_bank), 'YTickLabel', strsplit(num2str(dt_bank)));
set(gca, 'XTick', 1:length(x_bank), 'XTickLabel', strsplit(num2str(x_bank)));
hold on
plot([0,length(x_bank) + 1],[find(dt_bank == 0), find(dt_bank == 0)],'k--');
ConfAxis
end