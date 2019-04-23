function Figure5A_NaturalSceneDemo()
row_id = [206, 110, 89];
image_id = [3,3,8];
% load those images
n_hor = 927;
example_scene = zeros(3, n_hor);
S = GetSystemConfiguration;
image_dir = fullfile(S.natural_scene_simulation_path, 'image', 'statiche0', 'FWHM25');
image_info = dir(fullfile(image_dir, '*.mat'));
for ii = 1:1:3
    image_full_path = fullfile(image_dir, image_info(image_id(ii)).name);
    image_I = load(image_full_path);
    example_scene(ii, :) = image_I.I(row_id(ii),:);
end
example_scene = fliplr(example_scene);
%% find a way to squeeze them together. first, find the distance...
MakeFigure_Paper;
position_bank  = [[36, 500]; [36, 500 - 36]; [36, 500 - 36 * 2]];
plot_size      = [252,40]; 
% plot them
ylim = [[-0.3,0.15]; [-0.5,0.5]; [-0.5,1.25]];
yTick = [[-0.1, 0, 0.1];[-0.2, 0, 0.2]; [-0.5, 0, 0.5]];
color_bank = [[51, 102, 102]; [204, 102,51]; [204, 153, 102]]/255 ;
for ii = 1:1:3
    axes('Units', 'points', 'Position', [position_bank(ii, 1) + 14,position_bank(ii, 2),plot_size(1),plot_size(2)]);
    plot(example_scene(ii,:),'color',color_bank(ii, :));
    hold on
    plot([0, n_hor], [0,0], 'k--')
    set(gca, 'XTick',[]); 
    set(gca, 'YTick', yTick(ii,:));
    ylabel('contrast')
    ConfAxis
    axis('tight');
    set(gca, 'YLim', ylim(ii, :));
    ax = gca; set(ax.XAxis, 'Visible','off');
    ConfAxis('fontSize', 8, 'LineWidth', 0.5);
end
end

function find_example_scenes()
stim_statistics = collect_all_individual_scenes_statistics();

edges = {[0:0.02:0.16, 1]', [-3, -1:0.5:3, 8]', [0,45]'};
X =  [stim_statistics.variance(:), stim_statistics.skewness(:)];

%% group data according to variance and skewness...
var_num = 1;
skew_num = 2;
n_bin_skew = length(edges{skew_num}) - 1;
n_bin_var = length(edges{var_num}) - 1;
% group the data using the edges and X. two d is not that hard. do it.
ind_2d = cell(n_bin_skew, n_bin_var);
for ii = 1:1:n_bin_skew
    for jj = 1:1:n_bin_var
        ind_2d{ii, jj} = find(X(:, skew_num) < edges{skew_num}(ii + 1) ...
            & X(:, skew_num) > edges{skew_num}(ii)...
            & X(:, var_num) < edges{var_num}(jj + 1)...
            & X(:, var_num) > edges{var_num}(jj));
    end
end

%% three example points.
idx_bank = zeros(3, 1);

% example 1, low variance, negative skew
idx = ind_2d{2, 1};
idx_bank(1) = idx(17);

% example 2, low variance, positive skew
idx = ind_2d{6, 1};
idx_bank(2) = idx(2);

% example 3, high variance, positive skew
idx = ind_2d{6, 4};
idx_bank(3) = idx(30);

% Get the corresponding ID.
n_row = 251;
n_image = 421;
[row_id,image_id] = ind2sub([n_row, n_image], idx_bank);

for ii = 1:1:3
    disp(ii)
    stim_statistics.variance(row_id(ii), image_id(ii))
    stim_statistics.skewness(row_id(ii), image_id(ii))
    stim_statistics.kurtosis(row_id(ii), image_id(ii))
end
end

