function plot_three_example_scene(example_scene, position_bank,plot_size, color_bank, yTick, ylim)


n_hor = size(example_scene, 2);
for ii = 1:1:3
    axes('Units', 'points', 'Position', [position_bank(ii, 1) + 14,position_bank(ii, 2),plot_size(ii,1),plot_size(ii,2)]);
    plot(example_scene(ii,:),'color',color_bank(ii, :));
    hold on
    plot([0, n_hor], [0,0], 'k--')
    set(gca, 'XTick',[]); 
    set(gca, 'YTick', yTick(ii,:));
    ylabel('contrast')
    axis('tight');
    set(gca, 'YLim', ylim(ii, :));
%     text(0, ylim(ii,2), num2str(var(example_scene(ii,:)), 5));
%     text(0, ylim(ii,2)-0.25, num2str(skewness(example_scene(ii,:)), 5));
    ax = gca; set(ax.XAxis, 'Visible','off');
    set(gca, 'Clipping', 'off');
    ConfAxis('fontSize', 8, 'LineWidth', 0.5);
end
end