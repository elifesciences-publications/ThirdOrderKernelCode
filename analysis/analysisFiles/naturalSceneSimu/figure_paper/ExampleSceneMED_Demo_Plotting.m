function ExampleSceneMED_Demo_Plotting(med, p_i, I, varargin)
%% 
plot_natural_scene_flag = 1;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%%
n_hor = 927;
MakeFigure_Paper;
position_bank  = [[36, 500]; [36, 500 - 30]; [36, 500 - 30 * 2]];
plot_size      = [[233,50];[233,40];[233,40]];
% plot them
ylim = [[-2,3]; [-2,2]; [-2,2]];
yTick = [[-1, 0, 1];[-1, 0, 1]; [-1, 0, 1]];
color_bank = [;[0,0,0]; [51, 102, 153];[255,51,51]]/255 ;
if plot_natural_scene_flag
    ii_start = 1;
else
    ii_start = 2;
end
for ii = ii_start:1:3
    axes('Units', 'points', 'Position', [position_bank(ii, 1) + 14,position_bank(ii, 2),plot_size(ii,1),plot_size(ii,2)]);
    plot(I{ii},'color',color_bank(ii, :));
    hold on
    plot([0, n_hor], [0,0], 'k--')
    set(gca, 'XTick',[]); 
    set(gca, 'YTick', yTick(ii,:));
    ylabel('contrast')
    ConfAxis
    axis('tight');
    set(gca, 'YLim', ylim(ii, :));
%     text(0, ylim(ii,2), num2str(var(example_scene(ii,:)), 5));
%     text(0, ylim(ii,2)-0.25, num2str(skewness(example_scene(ii,:)), 5));
    ax = gca; set(ax.XAxis, 'Visible','off');
    ConfAxis('fontSize', 8, 'LineWidth', 0.5);
end


axes('Units', 'points', 'Position',  [300, 500 - 30 * 2 + 5, 108, 100]);
hold on
plot_contrast_distribution(med{1}, p_i{1}, p_i{2}, I{1}, 1, 0, plot_natural_scene_flag)
% plot([med{1}.gray_value(1),med{1}.gray_value(1)], get(gca, 'YLim'), 'k--');
% plot([med{1}.gray_value(end),med{1}.gray_value(end)], get(gca, 'YLim'),'k--');
    
plot([med{1}.mu_true(1),med{1}.mu_true(1)], get(gca, 'YLim'),'k--');
ConfAxis('fontSize', 8, 'LineWidth', 0.5);

end