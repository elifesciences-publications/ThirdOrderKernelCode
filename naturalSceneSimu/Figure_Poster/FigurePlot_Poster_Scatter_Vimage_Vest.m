function FigurePlot_Poster_Scatter_Vimage_Vest(v_real, v_estimates, h)
ylabel_str = 'HRC output';
%% units would be point... 150.
axes('Units', h.Units, 'Position', h.Position);
scatter(v_real, v_estimates, 'k.');
max_val = max(abs(v_estimates));
ylim = [-max_val, max_val];
Velocity_ScatterPlot_Utils('image velocity', ylabel_str, 'y_lim_flag', 1, 'ylim', ylim );
xlim = get(gca, 'XLim'); ylim = get(gca, 'YLim');
text(xlim(2),  ylim(2),   ['r = ', num2str(corr(v_estimates, v_real))],'FontSize', 20);
ConfAxis
% ConfAxis('fontSize')

end