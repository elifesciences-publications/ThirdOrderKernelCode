function [scene_stim, improvement_metric,  data,  r_all] =  Analysis_ThirdAllLocations_OrganizeFWHMdata(FWHM_bank, which_kernel_type, metric)
scene_stim = [];
% std_ratio_v23_over_v2 = [];
% for ii = 1:1:length(FWHM_bank)
%     FWHM = FWHM_bank(ii);
%     [scene_stim_this, std_ratio_v23_over_v2_this]  = get_data_from_one_FWHM(FWHM);
%     scene_stim = cat(1,scene_stim, scene_stim_this);
%     std_ratio_v23_over_v2 = cat(1, std_ratio_v23_over_v2, std_ratio_v23_over_v2_this');
% end
data = [];
for ii = 1:1:length(FWHM_bank)
    FWHM = FWHM_bank(ii);
    [scene_stim_this, improvement_metric,  data, r_all]  = get_data_from_one_FWHM_GauVel(FWHM, which_kernel_type, metric);
    scene_stim = cat(1,scene_stim, scene_stim_this);
    improvement_metric = cat(1, improvement_metric');
end
end

function [scene_stim, improvement_metric, data, r_all]  = get_data_from_one_FWHM_GauVel(FWHM, which_kernel_type, metric)
scaling_factor = 1;
synthetic_type = ['nsFWHM', num2str(FWHM)];
spatial_average_flag = true;
% which_kernel_type = 'rc_localscene_gauvel';
% which_kernel_type = 'local_scene_gauvel_highsk';
data = Analysis_Utils_GetData_OneRowAllPhase_GauVel(synthetic_type, which_kernel_type,'spatial_average_flag', spatial_average_flag);

if strcmp('local_scene_synthetic', which_kernel_type)
    data.v2 = data.v2 * scaling_factor.^2;
    data.v3 = data.v3 * scaling_factor.^3;
    % symmetrize skewness... flip scene...
%     data.v2 = cat(2, data.v2, data.v2);
%     data.v3 = cat(2, data.v3, -data.v3);
%     data.v_real = cat(2, data.v_real, data.v_real);
end
%% have a seperate function to analyze each indivdual velocity. you have that plot. and function, find it.

%% analyze the scene statistics
% dependend on the amount of data you have.
[n_total_velocity, n_total_image] = size(data.v2);
r_all = zeros(n_total_image, 4);
plot_flag = false;
for ss = 1:1:n_total_image
    % for every image.
    data_this.v2 = data.v2(:, ss);
    data_this.v3 = data.v3(:, ss);
    data_this.v_real  = data.v_real(:,ss);
    [metric_batches,  ~] = plot_scatter_plot_correlation_one_situation(data_this, 'matlab_debug','plot_flag', plot_flag);
    r_all(ss, :) = metric_batches.mean;
end
%% look at the ratio.
switch metric
    case 'corr_improvement'
        improvement_metric = (r_all(:, 3) - r_all(:, 1))./r_all(:, 1);
    case 'error_reduction'
        unexplained_variance = 1 - r_all.^2;
        improvement_metric = (unexplained_variance(:, 1) - unexplained_variance(:,3))./ unexplained_variance(:, 1);
end
switch which_kernel_type
    case 'local_scene_gauvel_highsk'
        load('D:\JuyueLog\2017_09_20\image_for_hgihsk.mat');
    case 'local_scene_preselect'
        load('D:\JuyueLog\2017_09_20\image_set_10.mat');
        n_data_set = 6; % hard coded here..
        scene_stim = [];
        for ii = 1:1:n_data_set
            data_sequence = Generate_VisStimVelEst_Utils_GenerateImageSequence_PreSelect(image_set(ii).image_ID, image_set(ii).image_row);
            scene_stim_this = reload_images_used_for_scramble_phase_analysis([], false, [], FWHM, [], ...
                'preselect_image', true, 'data_sequence_image_421_input', data_sequence);
            scene_stim = cat(1, scene_stim,scene_stim_this);
        end
    case 'local_scene_preselect_cons_moments'
        scene_file = 'D:\Natural_Scene_Simu\image\statiche0syn_cons_moments_preselect\FWHM25';
        n_data_set = 10;
        scene_stim = [];
        for ii  = 1:1:n_data_set
            I = load(fullfile(scene_file, ['set_', num2str(ii)]));
            scene_stim = cat(1, scene_stim, I.I);
        end
    case 'local_scene_synthetic'
        load('D:\Natural_Scene_Simu\image\staticche0syn_cons_moments\fix_variance_stim_scene.mat');
        scene_stim = scene_stim * scaling_factor;
%         scene_stim = cat(1, scene_stim, -scene_stim);
    case 'local_scene_synthetic_low_variance'
        load('D:\JuyueLog\2017_09_05\fix_variance_stim_scene_low_variance.mat');
        
    case 'rc_localscene_gauvel'
        n_hor = 927;
        n_total_sample_points = 1500;
        n_batch = floor(n_total_image/n_total_sample_points);
        scene_stim = zeros(n_total_image, n_hor);
        for ii = 1:1:n_batch
            scene_stim((ii - 1) * n_total_sample_points + 1: ii * n_total_sample_points, :) = reload_images_used_for_scramble_phase_analysis(n_total_sample_points, false, [], FWHM, ii - 1);
        end
end
end


function [scene_stim, sn_ratio_v23_over_v2_ns_within_scene_average_over_velocity]  = get_data_from_one_FWHM(FWHM, seed_num_bank)
vel_range_bank = 25:25:100;

synthetic_type = ['nsFWHM', num2str(FWHM)];
spatial_average_flag = true;
which_kernel_type = 'rc_a_scene_all_locations';
data = Analysis_Utils_GetData_OneRowAllPhase(synthetic_type, which_kernel_type,'spatial_average_flag', spatial_average_flag);

%% analyze the motion estimates
% The third order kernel does not help improve individual on average. find the scene where the third order is improved on average.
D = cat(4,data.v2, data.v3, data.v2 + data.v3);
v_real =vel_range_bank;
[n_hor, n_vel, n_scene, ~, n_noise] = size(D);
sn_ratio_v23_over_v2_all = zeros(n_vel, n_scene);
std_ratio_v23_over_v2_all = zeros(n_vel, n_scene);
for ss = 1:1:n_scene
    %% change the std to signal to ratio.
    std_ratio_v23_over_v2 = scatter_plot_one_scene_vest_vreal_no_scramble_different_metric(squeeze(D(:, :, ss, :)), v_real, 'std_ratio', true);
    std_ratio_v23_over_v2_all(:, ss) =  std_ratio_v23_over_v2;
    sn_ratio_v23_over_v2 =  scatter_plot_one_scene_vest_vreal_no_scramble_different_metric(squeeze(D(:, :, ss, :)), v_real, 'sig_noise_ratio',false);
    sn_ratio_v23_over_v2_all(:, ss) = sn_ratio_v23_over_v2;
end

%% analyze the scene statistics
% dependend on the amount of data you have.
n_total_sample_points = 2000;

n_batch = floor(n_scene/n_total_sample_points);
scene_stim = zeros(n_scene, n_hor);
for ii = 1:1:n_batch
    scene_stim((ii - 1) * n_total_sample_points + 1: ii * n_total_sample_points, :) = reload_images_used_for_scramble_phase_analysis(n_total_sample_points, false, [], FWHM, ii);
end
sn_ratio_v23_over_v2_ns_within_scene_average_over_velocity = squeeze(mean(sn_ratio_v23_over_v2_all, 1));
end