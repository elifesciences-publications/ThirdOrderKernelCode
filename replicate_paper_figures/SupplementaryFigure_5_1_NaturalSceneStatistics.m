function SupplementaryFigure_5_1_NaturalSceneStatistics()

%% plot statistics for FWHM 25 degree.
% stim_statistics = collect_all_individual_scenes_statistics();
S = GetSystemConfiguration;
data = load(fullfile(S.natural_scene_simulation_path, 'natural_scene_statistics.mat'));
stim_statistics = data.stim_statistics{2};
n_scene = numel(stim_statistics.mean);
%%
edges = {[0:0.02:0.16, 1]', [-3, -1:0.5:3, 8]', [0,3,6, 45]',[-1,-0.4:0.1:0.3, 1]'};
X_natural = [stim_statistics.variance(:), stim_statistics.skewness(:), stim_statistics.kurtosis(:), stim_statistics.mean(:)];
Y_density = ones(length(stim_statistics.variance(:)), 1);
[~, stats_sum_each_bin] = BinThreeD(X_natural(:, 1:3), Y_density, edges(1:3));
stats_density = stats_sum_each_bin/n_scene ;

%% also generate the the histogram. Leave it to later.
MakeFigure_Paper;
position_bank = [[36, 500]; [180, 500]; [324, 500]; [468, 500]];
plot_size = [108, 108];

X_natural = [stim_statistics.mean(:),stim_statistics.variance(:), stim_statistics.skewness(:), stim_statistics.kurtosis(:)];
statisticts_str = {'mean (c)','variance (c^2)', 'skewness (unitless)','kurtosis (unitless)'};
xlim_ = {[-1,1],[0,0.4],[-5,5],[0,20]};
numbins = [150,50,100,50];
for ii = 1:1:4
    axes('Units', 'points', 'Position', [position_bank(ii, 1) + 14,position_bank(ii, 2),plot_size(1),plot_size(2)]);
    % all the histogram uses the line plot.
    [N, edges_this] = histcounts(X_natural(:, ii), numbins(ii),  'Normalization','probability');
    plot((edges_this(1:end - 1) + edges_this(2:end))/2, N, 'k-');
    xlabel(statisticts_str{ii});
    ylabel('relative frequency');
    
    mean_sta = mean(X_natural(:, ii));
    hold on
    plot([mean_sta, mean_sta], get(gca, 'YLim'),'k--');
    set(gca,'XLim',xlim_{ii});
    ax = gca;
    set(ax.YAxis, 'Visible', 'off')
    ConfAxis('LineWidth', 0.5, 'fontSize', 8);
    
end

%% color plot 3D.
MakeFigure_Paper;
position_bank = [56, 500; 220, 500; 384, 500];

ii = 3;
used_variable = setdiff([1:3], ii);
xlabelstr = statisticts_str{used_variable(1)};
ylabelstr = statisticts_str{used_variable(2)};
x_edges = edges{used_variable(1)};
y_edges = edges{used_variable(2)};
clim = [-max(stats_density(:)),max(stats_density(:))];
for jj = 1:1:length(edges{ii}) - 1
    axes('Units', 'points', 'Position', [position_bank(jj, 1),position_bank(jj, 2),plot_size(1),plot_size(2)]);
    switch ii
        case 1
            stats_denstiy_2d =  squeeze(stats_density(jj, :, :));
        case 2
            stats_denstiy_2d =  squeeze(stats_density(:, jj, :));
        case 3
            stats_denstiy_2d =  squeeze(stats_density(:, :, jj));
    end
    NS_ns_statistics_density2d_visual_paper_version(stats_denstiy_2d, xlabelstr, ylabelstr, x_edges, y_edges, ...
        'clim_flag', 1, 'clim', clim);
    %     c = colorbar;
    
    % title string.
    controlling_variable_edge_str = [num2str(edges{ii}(jj)),' ~ ', num2str(edges{ii}(jj + 1))];
    title([statisticts_str{ii},' : ', controlling_variable_edge_str]);
    ConfAxis('LineWidth', 0.5, 'fontSize', 8);
    box on
end

%% get a plot with color bar.
position_bank = [56, 500; 220, 500; 384, 500];
plot_size = [108, 108];

ii = 3;
used_variable = setdiff([1:3], ii);
xlabelstr = statisticts_str{used_variable(1)};
ylabelstr = statisticts_str{used_variable(2)};
x_edges = edges{used_variable(1)};
y_edges = edges{used_variable(2)};
clim = [-max(stats_density(:)),max(stats_density(:))];
for jj = 1:1:length(edges{ii}) - 1
    axes('Units', 'points', 'Position', [position_bank(jj, 1),position_bank(jj, 2) - 200,plot_size(1),plot_size(2)]);
    switch ii
        case 1
            stats_denstiy_2d =  squeeze(stats_density(jj, :, :));
        case 2
            stats_denstiy_2d =  squeeze(stats_density(:, jj, :));
        case 3
            stats_denstiy_2d =  squeeze(stats_density(:, :, jj));
    end
    NS_ns_statistics_density2d_visual_paper_version(stats_denstiy_2d, xlabelstr, ylabelstr, x_edges, y_edges, ...
        'clim_flag', 1, 'clim', clim);
    c = colorbar;
    
    % title string.
    controlling_variable_edge_str = [num2str(edges{ii}(jj)),' ~ ', num2str(edges{ii}(jj + 1))];
    title([statisticts_str{ii},' : ', controlling_variable_edge_str]);
    box on
    ConfAxis('LineWidth', 0.5, 'fontSize', 8);
end

end



