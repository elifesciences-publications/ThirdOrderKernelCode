function K2_CovarianceMatrix_Visualization_dx_dt_plot(dx_dt, dt_bank, dx_bank,varargin)

quickViewOneKernel(dx_dt,1,'labelFlag',false);
% plot the middle line.
xlim = get(gca,'XLim');
ylim = get(gca,'YLim');
hold on
% determine what is the center,
dt_middle_line = ceil(length(dt_bank)/2);
plot(xlim,[dt_middle_line,dt_middle_line],'k-');
% determined by which 
dx_middle_line = find(dx_bank == 0);
plot([dx_middle_line,dx_middle_line],ylim,'k-');
xlabel('dx');
ylabel('dt');
set(gca,'YTick',1:length(dt_bank),'YTickLabel',strsplit(num2str(dt_bank)));
set(gca,'XTick', 1:length(dx_bank), 'XTickLabel', strsplit(num2str(dx_bank)));
ConfAxis

end