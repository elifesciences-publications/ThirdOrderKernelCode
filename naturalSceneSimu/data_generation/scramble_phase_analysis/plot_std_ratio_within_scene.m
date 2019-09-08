function [std_ratio_scrambling_phase_v2_over_v2,std_ratio_v23_over_v2_ns, p_sig_std_ratio_v23_over_v2,std_ratio_v23_over_V2_scramble]...
    = plot_std_ratio_within_scene(v_real, D)
[n_hor, n_vel, n_scene, ~, n_noise] = size(D);
n_noise = n_noise - 1;
std_ratio_scrambling_phase_v2_over_v2 = zeros(n_noise, n_vel, n_scene);
std_ratio_v23_over_v2_ns = zeros(1, n_vel, n_scene);
p_sig_std_ratio_v23_over_v2 = zeros(1, n_vel, n_scene);
std_ratio_v23_over_V2_scramble = zeros(n_noise, n_vel, n_scene);
plot_flag = false;
for ss = 1:n_scene
    [std_ratio_scrambling_phase_v2_over_v2(:, :, ss),...
        std_ratio_v23_over_v2_ns(:, :, ss), p_sig_std_ratio_v23_over_v2(:, :, ss),...
        std_ratio_v23_over_V2_scramble(:, :, ss)]=...
        plot_scatter_plot_for_one_scene_vest_vreal_v2(squeeze(D(:,:,ss,:,:)), v_real, n_noise, plot_flag);
end

% calculate everything across scenes.
mean_v2_over_v2_scrambling_across_scenes = mean(std_ratio_scrambling_phase_v2_over_v2, 3);
mean_v23_over_v2_ns_across_scenes = mean( std_ratio_v23_over_v2_ns, 3);
mean_v23_over_v2_scrambling_across_scenes = mean(std_ratio_v23_over_V2_scramble, 3);

%% first, plot the bar plot.
MakeFigure;
subplot(3,1,1)
color_bank = {[0,0,0],[1,0,0],[0.5,0.5,0.5]};
std_ratio_v23_over_v2_all = cat(1, mean(mean_v2_over_v2_scrambling_across_scenes, 1), ...
    mean_v23_over_v2_ns_across_scenes,...
    mean(mean_v23_over_v2_scrambling_across_scenes, 1));
mean_p_sig_std_ratio_v23_over_v2 = zeros(n_vel, 1);
scene_condition_str = {'natural scene','scramble phase'};
plot_bar_std_ratio_v23_over_v2(v_real, std_ratio_v23_over_v2_all,mean_p_sig_std_ratio_v23_over_v2, color_bank, scene_condition_str)

%% second, plot the histogram across all scrambling cases.
h_axes = repmat(struct('Units','normalized','Position', []), n_vel, 1);
for vv = 1:1:n_vel
    axes_subplot = subplot(3, n_vel, n_vel + vv);
    h_axes(vv).Position= axes_subplot.Position;
end
plot_std_ratio_histogram(v_real, mean_v2_over_v2_scrambling_across_scenes, mean_v23_over_v2_scrambling_across_scenes, mean_v23_over_v2_ns_across_scenes,  color_bank, h_axes)
end