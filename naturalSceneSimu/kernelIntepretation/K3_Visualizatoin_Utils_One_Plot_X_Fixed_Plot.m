function K3_Visualizatoin_Utils_One_Plot_X_Fixed_Plot(data_for_plot, x_fixed, dx_bank_plot, dt_vary)

%% consider set the color scheme to be the same.
quickViewOneKernel(data_for_plot,1, 'labelFlag', false);
% label everything
xlabel('dx'); set(gca, 'XTick', [1:length(dx_bank_plot)] ,'XTickLabel', {'-2','-1','1','2'});
ylabel('\tau2 - \tau1');
ylabel_str = strsplit(num2str([(flipud(dt_vary))', -dt_vary' ]));
set(gca, 'YTick', [1:2 * length(dt_vary)], 'YTickLabel', ylabel_str);
ConfAxis
% plot the line in converging/diverging transition.
hold on
plot(get(gca,'XLim'),[length(dt_vary)+1/2,length(dt_vary)+1/2],'k-')
end