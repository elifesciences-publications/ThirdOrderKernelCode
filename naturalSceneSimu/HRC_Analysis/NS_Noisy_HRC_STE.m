function NS_Noisy_HRC_STE( which_kernel_type, y_label_str)
    
%% load data
%% take a look at the scr
spatial_average_flag = true;
visual_stimulus_relative_path = 'ensemble_scrambling';
data = Analysis_Utils_GetData_OneRowAllPhase_GauVel(visual_stimulus_relative_path,...
    which_kernel_type,'spatial_average_flag', spatial_average_flag);

%% every select some data point.
size_v2 = size(data.v2);
idx = [];
for seed = 1:1:1
    rng(seed);
    which_velocity_to_use = randi(size_v2(1), [size_v2(2),1]);
    idx  = [idx; sub2ind(size_v2, which_velocity_to_use, [1:size_v2(2)]')];
end
data_ns.v2 = data.v2(idx);
data_ns.v_real = data.v_real(idx);

%% get the correlation number.
data_batches = performance_evaluation_utils_data_segmentation(data_ns, 10);
[metric_batches, ~, ~, ~] = performance_evaluation_utils_data_calculate_correlation_batch(data_batches, 'corr_improvement');


%% plot the result.
v2_ns = [data_ns.v2; - data_ns.v2];
v_real_ns = [data_ns.v_real; -data_ns.v_real];
position_bank = {[200,300,250,250],[500,500,150,150]}; %plot first and scale them
h = repmat(struct('Position',[],'Units', 'points'), 2,1);
for ii = 1:1:2
    h(ii).Position = position_bank{ii};
end
MakeFigure;
axes('Units', h(1).Units, 'Position', h(1).Position);
scatter(v_real_ns, v2_ns , 'Marker','.', 'MarkerEdgeColor', [0,0,0], 'MarkerFaceColor', [0,0,0]);
Velocity_ScatterPlot_Utils('image velocity', y_label_str,'y_lim_flag', 0,'xLim', [-600, 600]);
r_str = sprintf('%.2f +/- %.2f', metric_batches.mean, metric_batches.sem);
text(500,  max(get(gca, 'YLim')),   ['r = ', r_str],'FontSize', 20);
ConfAxis

MySaveFig_Juyue(gcf, 'Ensemble_Scrambling_gau', which_kernel_type, 'nFigSave',2,'fileType',{'png','fig'});
end