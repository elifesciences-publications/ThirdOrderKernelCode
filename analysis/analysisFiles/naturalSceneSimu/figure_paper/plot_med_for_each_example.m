function plot_med_for_each_example(med_solu, stim_ns)
% first, calculate the distribution...
[~,~, p_i] = MaxEntDis_ConsMoments_Utils_PlotResult...
    (med_solu.x_solved, med_solu.gray_value, med_solu.mu_true, med_solu.cov_true, 3, med_solu.N, med_solu.K);

med_solu_contrast. p_i =  p_i(:, 1);
med_solu_contrast.gray_value = med_solu.gray_value;

%%
[time_series_scale_back_upsample_used,time_series_scale_back_used]  ...
    = MaxEntDist_ConsMoments_Utils_Sampling_OneScene(med_solu.x_solved, med_solu.gray_value, med_solu.N, med_solu.K, med_solu.resolution_n_pixel, ...
    'plot_flag', false, 'n_hor', 100000,'n_sample', 100000);
MaxEntDis_Utils_Gibbs_Utils_PlotOneTimeSeries(time_series_scale_back_used, med_solu.gray_value,med_solu.N, med_solu.K);

%% first, plot the contrast distribution of these three...
MakeFigure;
position_bank = {[50, 100, 150, 125],[250,100, 150,125],[550,100, 150, 125]};
color_this = [0,0,0];

% color_different_scenes = brewermap(2, 'Accent');

h_axes = repmat(struct('Position',[],'Units', 'points'), 3, 1);
for ii = 1:1:3
    h_axes(ii).Position = position_bank{ii};
end

axes('Units', h_axes(1).Units, 'Position', h_axes(1).Position);
natural_scene_histogram_temp(stim_ns,med_solu.gray_value, color_this);
xlabel('contrast');
ylabel('log(probability)')

axes('Units', h_axes(2).Units, 'Position', h_axes(2).Position);
medp_plot_matchup(med_solu.gray_value, med_solu_contrast. p_i, [1, 0,0]);
% set(gca, 'YTick',[]);
xlabel('contrast');

axes('Units', h_axes(3).Units, 'Position', h_axes(3).Position);
color_ns = [0,0,0];
color_sample = [1,0,0];
color_model = [1,0,0];
plot_spatial_correlation_temp_scene(stim_ns, color_ns);
hold on
plot_spatial_correlation_temp_scene(time_series_scale_back_upsample_used, color_sample);
plot_spatial_correlation_temp_med(med_solu.resolution_n_pixel, med_solu.correlation_true, color_model, med_solu.K);
set(gca, 'YLim', [0, 1]);
hold on; plot(get(gca, 'XLim'), [0,0],'k-');
xlabel('spatial offset [\circ]')
ylabel('correlation')
title('spatial correlation');
ConfAxis;
% MySaveFig_Juyue(gcf, 'MaxEntropyDistribution','ContrastSpatial_v2', 'nFigSave',2,'fileType',{'eps','fig'});


end