function SynData_MultiSyn_SummaryPlot_Utils_LinePlot_GroupedByCondition(improvement_all_various_skew, x_value, x_tick_str_skew)
improvement_struct = [improvement_all_various_skew{:}];
improvement_mean = [improvement_struct(:).mean];
improvement_sem = [improvement_struct(:).sem];
%%

plot(x_value, improvement_mean,'b');
hold on
for ii = 1:1:length(x_value)
    plot([x_value(ii), x_value(ii)], [improvement_mean(ii) + improvement_sem(ii), improvement_mean(ii) - improvement_sem(ii)],'b');
end
plot(get(gca, 'XLim'),[0,0],'k--');
y_value_max = max(abs(get(gca, 'YLim')));
x_value_max = 1.1 * max(abs(x_value));
set(gca, 'YLim', [-y_value_max, y_value_max],'XLim', [-x_value_max, x_value_max]);
set(gca, 'XTick', x_value, 'XTickLabel', x_tick_str_skew)

% MySaveFig_Juyue(gcf, 'Ensemble_Skewness_Fold_Change','one_curve', 'nFigSave',2,'fileType',{'png','fig'});

end