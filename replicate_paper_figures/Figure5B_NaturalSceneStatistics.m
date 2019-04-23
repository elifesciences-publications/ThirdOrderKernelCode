function Figure5B_NaturalSceneStatistics()

%% plot statistics for FWHM 25 degree.
% stim_statistics = collect_all_individual_scenes_statistics();
S = GetSystemConfiguration;
data = load(fullfile(S.natural_scene_simulation_path, 'natural_scene_statistics.mat'));
stim_statistics = data.stim_statistics{2}; % The second is the 25.
n_scene = numel(stim_statistics.mean);

%% also plot 2D. skewness and variance.
MakeFigure_Paper; 

position_bank = [56, 500; 220, 500; 384, 500];
density_size = [108, 108];

axes('Units', 'points', 'Position', [position_bank(1, 1),position_bank(1, 2),density_size(1),density_size(2)]);
clim = [-0.15, 0.15];
X_natural = [stim_statistics.variance(:), stim_statistics.skewness(:), stim_statistics.kurtosis(:), stim_statistics.mean(:)];
Y_density = ones(length(stim_statistics.variance(:)), 1);

edges_new = {[0:0.02:0.16, 1]', [-3, -1:0.5:3, 8]', [0,45]'};
[~, stats_sum_each_bin] = BinThreeD(X_natural(:, 1:3), Y_density, edges_new(1:3));
stats_density_only_variance_skewness = squeeze(stats_sum_each_bin)/n_scene ;

% set up the labeling.
xlabelstr = 'variance (c^2)';
ylabelstr = 'skewness (unitless)';
x_edges = edges_new{1};
y_edges = edges_new{2};
% clim = [-max(stats_density_only_variance_skewness(:)),max(stats_density_only_variance_skewness(:))];
NS_ns_statistics_density2d_visual_paper_version(stats_density_only_variance_skewness, xlabelstr, ylabelstr, x_edges, y_edges, ...
    'clim_flag', 1, 'clim', clim);
ConfAxis('fontSize', 8, 'LineWidth', 0.5);
box on
axis tight
axis equal

%% also plot 2D. skewness and kurtosis
axes('Units', 'points', 'Position', [position_bank(2, 1),position_bank(2, 2),density_size(1),density_size(2)]);
edges_new = {[0, 1]', [-3, -1:0.5:3, 8]', [0,1.5,3,4.5,6,7.5,9,10.5,12, 45]'};
[stats_count_each_bin, ~] = BinThreeD(X_natural(:, 1:3), Y_density, edges_new(1:3));
stats_density_only_skewness_kurtosis = squeeze(stats_count_each_bin)/n_scene ;
xlabelstr = 'skewness';
ylabelstr = 'kurtosis (unitless)';
x_edges = edges_new{2};
y_edges = edges_new{3};

% plot..
NS_ns_statistics_density2d_visual_paper_version(stats_density_only_skewness_kurtosis', ylabelstr, xlabelstr, y_edges, x_edges, ...
    'clim_flag', 1, 'clim', clim);

ConfAxis('fontSize', 8, 'LineWidth', 0.5);
box on
axis equal
axis tight

%% get the color bar
axes('Units', 'points', 'Position', [position_bank(3, 1),position_bank(3, 2),density_size(1),density_size(2)]);
NS_ns_statistics_density2d_visual_paper_version(stats_density_only_skewness_kurtosis', ylabelstr, xlabelstr, y_edges, x_edges, ...
    'clim_flag', 1, 'clim', clim);
ConfAxis('fontSize', 8, 'LineWidth', 0.5);
box on
end