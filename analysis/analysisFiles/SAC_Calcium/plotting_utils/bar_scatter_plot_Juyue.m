function bar_scatter_plot_Juyue(data_ave, data_sem, data_points, color_bank)
n_data = length(data_ave);
for ii = 1:1:n_data
    hold on;
    bar(ii, data_ave(ii),'FaceColor', color_bank(ii,:), 'EdgeColor', color_bank(ii,:));
    hold off;
end
for ii = 1:1:n_data
    PlotErrorBar_Juyue(ii, data_ave(ii), data_sem(ii));
end
if size(data_points, 1) > 2
    XYPos = scatterBar(data_points);
    for ii = 1:1:n_data
        hold on;
        h = scatter(XYPos(:, 1, ii), XYPos(:, 2, ii), '.','MarkerEdgeColor', color_bank(ii,:));
        h.Annotation.LegendInformation.IconDisplayStyle = 'off';
        hold off;
    end
    set(gca, 'XTick',[]);
end
end