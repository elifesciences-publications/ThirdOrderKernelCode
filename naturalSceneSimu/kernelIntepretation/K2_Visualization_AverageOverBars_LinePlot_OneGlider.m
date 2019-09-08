% here is a small function for plotting the thing...
function K2_Visualization_AverageOverBars_LinePlot_OneGlider(dt_bank, dt_x_dx_plot_average_over_bar, resp_sem, shuffle_std, shuffle_mean, p_val, maxValue, alpha, varargin)
label_flag = true;
dx_label_flag = false;
dx = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

timeUnit = 1/60;
dt_x_dx_plot_average_over_bar = dt_x_dx_plot_average_over_bar / timeUnit^2;
resp_sem = resp_sem/timeUnit^2;
shuffle_std = shuffle_std/timeUnit^2;
shuffle_mean = shuffle_mean/timeUnit^2;
maxValue = maxValue/timeUnit^2;

PlotXY_Juyue(dt_bank',dt_x_dx_plot_average_over_bar,'errorBarFlag',true,'sem',resp_sem ,'limPreSetFlag',true,'maxValue',maxValue,...
    'colorMean',[1,0,0],'colorError',[1,0,0]);
% hold on; plot(dt_bank',shuffle_std + shuffle_mean,'b--'); plot(dt_bank',-shuffle_std + shuffle_mean,'b--');
% FigPlot_SK_Utils_GliderSignificance(dt_bank',p_val,alpha, maxValue ,false);

XTick = get(gca, 'XTick');
XTickLabel = strsplit(num2str((dt_bank(ismember(dt_bank, XTick)) * 1/60),'%.3f '));
set(gca, 'XTickLabel', XTickLabel);
ConfAxis


if label_flag
    xlabel('temporal interval [s]');
    ylabel(['\deltaF /F / (contrast^2 * sec^2)'])
end

if dx_label_flag
    t = text(15, 0, [num2str(dx *  5),'degree']);
    t.FontSize = 20;

end
end