function Figure5FG_SupplementaryFigure5_2C_FixedSkewnessDemo()
%% image 1 and 20 row. get
%% Solution, plot all of them? Log Scale or linear scale..
solution_folder_name = {'statiche0syn_pixel_dist_ivar_solution',...
    'statiche0_pixel_dist_fixedskew_025_solu',...
    'statiche0_pixel_dist_fixedskew_050_solu',...
    'statiche0_pixel_dist_fixedskew_075_solu',...
    'statiche0_pixel_dist_fixedskew_1_solu',...
    'statiche0_pixel_dist_fixedskew_125_solu'};

%% image
syn_image_folder_name = {'statiche0syn_pixel_dist_fixedskew_125_selective_neg',...
    'statiche0syn_pixel_dist_fixedskew_1_selective_neg',...
    'statiche0syn_pixel_dist_fixedskew_075_selective_neg',...
    'statiche0syn_pixel_dist_fixedskew_050_selective_neg',...
    'statiche0syn_pixel_dist_fixedskew_025_selective_neg',...
    'statiche0syn_pixel_dist_ivar',...
    'statiche0syn_pixel_dist_fixedskew_025_selective',...
    'statiche0syn_pixel_dist_fixedskew_050_selective',...
    'statiche0syn_pixel_dist_fixedskew_075_selective',...
    'statiche0syn_pixel_dist_fixedskew_1_selective',...
    'statiche0syn_pixel_dist_fixedskew_125_selective'};
%%
%% data set 1
S = GetSystemConfiguration;

image_id = 1;
row_id = 20;

%% load the med for all.
n_solution = length(solution_folder_name);
med_data = cell(n_solution, 1);
for ii = 1:1:n_solution
    med_data_image = load(fullfile(S.natural_scene_simulation_path, 'image',solution_folder_name{ii}, 'FWHM25\Image1.mat'));
    med_data{ii}= med_data_image.med(row_id);
end

med_tmp = med_data{1};
gray_value = med_tmp.gray_value;
N = med_tmp.N;
K = med_tmp.K;

med_p_full = cell(n_solution * 2 - 1, 1);
for ii = 1:1:n_solution
    if ii == 1
        [~, ~, med_p_tmp] = MaxEntDis_ConsMoments_Utils_PlotResult(med_data{ii}.x_solved, gray_value, med_data{ii}.mu_true, [], 2, N, K,'plot_flag',false);
        med_p_full{n_solution} = med_p_tmp;
    else
        [~, ~, med_p_tmp] = MaxEntDis_ConsMoments_Utils_PlotResult(med_data{ii}.x_solved,gray_value, med_data{ii}.mu_true, [], 3, N, K,'plot_flag',false);
        %%
        med_p_full{n_solution - ii + 1} = flipud(med_p_tmp);
        med_p_full{n_solution * 2 - (n_solution - ii + 1)} = med_p_tmp;
    end
end

%%
med_kurtosis = zeros(n_solution * 2 - 1, 1);
for ii = 1:1:n_solution * 2 - 1
    med_kurtosis(ii) = kurtosis_p(med_p_full{ii}, gray_value);
end

%% load the image example
image_data = cell(n_solution * 2 - 1, 1);
for ii = 1:1:n_solution * 2 - 1
    image_data_image = load(fullfile(S.natural_scene_simulation_path, 'image',syn_image_folder_name{ii},'\FWHM25\Image1.mat'));
    image_data{ii} = image_data_image.I(row_id, :);
end


%% Plot
color_bank = brewermap(n_solution * 2 - 1, 'Spectral'); color_bank = flipud(color_bank);


%% Plot example images
plot_num = [7, 9, 11];
color_bank_example_scene = color_bank(plot_num, :);
example_scene = zeros(3, length(image_data{1}));
for ii = 1:1:3
    example_scene(ii, :) = image_data{plot_num(ii)};
end

MakeFigure_Paper;
position_bank  = [[36, 500]; [36, 500 - 36]; [36, 500 - 36 * 2]];
plot_size      = [[233,40];[233,40];[233,40]];

ylim = [[-2,2];[-2,2];[-2,2]];
yTick = [[-1, 0, 1];[-1, 0, 1]; [-1, 0, 1]];
plot_three_example_scene(example_scene, position_bank, plot_size, color_bank_example_scene, yTick, ylim);
% MySaveFig_Juyue(gcf, 'fiexed_skew_demo_images','image1_row20','nFigSave',2,'fileType',{'pdf','fig'})


%% Plot probability distribution.
plot_num = 1:2:(2*n_solution - 1);
axes('Units', 'points', 'Position',  [300, 500 - 30 * 2 + 5, 108, 100]);
hold on
for ii = 1:1:length(plot_num)
    plot(gray_value, med_p_full{plot_num(ii)},'color',color_bank(plot_num(ii),:));hold on
end
set(gca,'XLim',[-3, 3], 'XTick', [-2, 0, 2]);
plot([0, 0], get(gca, 'YLim'),'k--');
legend_str = {'-1.25', '-1', '-0.75','-0.50','-0.25','0','0.25','0.5','0.75','1', '1.25'};
legend(legend_str(plot_num));
ConfAxis('fontSize', 8, 'LineWidth', 0.5);
xlabel('contrast')
% MySaveFig_Juyue(gcf, 'fiexed_skew_demo_MEDP','image1_row20','nFigSave',2,'fileType',{'pdf','fig'});

%% plot the kurtosis changed with skewness for example images.
axes('Units', 'points', 'Position',  [450, 500 - 30 * 2 + 5, 108, 100]);
hold on
plot([-1.25:0.25:1.25], med_kurtosis,'k.-', 'color',[0,0,0]);hold on
set(gca,'XLim',[-1.25, 1.25], 'XTick', [-1, -0.5, 0, 0.5, 1]);
set(gca,'YLim',[2, 6], 'XTick', [-1, -0.5, 0, 0.5, 1]);
xlabel('skewness')
ylabel('kurtosis')
plot([0, 0], get(gca, 'YLim'),'k--');
plot(get(gca, 'XLim'),[3, 3], 'k--');

ConfAxis('fontSize', 8, 'LineWidth', 0.5);
% MySaveFig_Juyue(gcf, 'fiexed_skew_demo_MED_kurtosis','image1_row20','nFigSave',2,'fileType',{'pdf','fig'});
end
