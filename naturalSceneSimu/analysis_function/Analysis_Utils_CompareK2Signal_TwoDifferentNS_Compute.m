function [all_scene, one_scene] = Analysis_Utils_CompareK2Signal_TwoDifferentNS_Compute(which_kernel_type, synthetic_type_bank, spatial_average_flag)
% synthetic_type_bank = {'ns_all_phase','sc_scramble_phase'};
D = cell(2, 1);
for ii = 1:1:2
    synthetic_type = synthetic_type_bank{ii};
    % you can determine whether to average over space here.
    data = Analysis_Utils_GetData_OneRowAllPhase(synthetic_type, which_kernel_type,'spatial_average_flag', spatial_average_flag);
    D{ii} = Analysis_Utils_PlotVelR_Binary_OneRowAllPhase( data );
end
%%
n_scene = D{1}.n_scenes;
n_vel = size(D{1}.v2_mean,1);
v_real_range = D{1}.v_real_range(:,1);

std_ratio = zeros(n_vel, n_scene);
ratio_meaned = zeros(n_vel, 1);
ratio_std = zeros(n_vel, 1);
for jj = 1:1:n_vel
    v2_std = zeros(n_scene, 2);
    for ii = 1:1:2
        v2_std(:,ii) = D{ii}.v2_std(jj, :);
    end
    std_ratio(jj,:) = v2_std(:,1)./v2_std(:,2);
    ratio_meaned(jj) = mean(std_ratio(jj,:));
    ratio_std(jj) = std(std_ratio(jj,:));
end
all_scene.v_real_range = v_real_range;
all_scene.ratio_meaned = ratio_meaned;
all_scene.ratio_std = ratio_std;
% MyScatter_DoubleErrBars(v_real_range, ratio_meaned, [], ratio_std , 'color',[0,0,0]);
% xlabel('image velocity');
% ylabel('mean ratio ns/scramble');
% ylim = get(gca, 'YLim');
% set(gca, 'YLim',[0,ylim(2)]);
% MySaveFig_Juyue(gcf,'HRC_Std_Ratio',spatial_average_str, 'nFigSave',2,'fileType',{'png','fig'});

%%
vel_plot = 100;
jj = find(vel_plot== v_real_range);
v2_std = zeros(n_scene, 2);
for ii = 1:1:2
    v2_std(:,ii) = D{ii}.v2_std(jj, :);
end
% got the largest 4?
ratio = v2_std(:,1)./v2_std(:,2);
[~, ss_sort] = sort(ratio,'descend');


kk = floor(prctile(ratio, 20));
ss = ss_sort(kk);
v_real_range = cell(2, 1);
v2_mean = cell(2, 1);
v2_std = cell(2, 1);
for ii = 1:1:2
    v_real_range{ii} = D{ii}.v_real_range(:,ss);
    v2_mean{ii} = D{ii}.v2_mean(:,ss);
    v2_std{ii} = D{ii}.v2_std(:,ss);
end
one_scene.v_real_range = v_real_range;
one_scene.v2_mean = v2_mean;
one_scene.v2_std = v2_std;
% MySaveFig_Juyue(gcf,'HRC_IndiviualImages_MeanAndStd',spatial_average_str, 'nFigSave',1,'fileType',{'png'});

% mean value is smaller. not symmetric. very interesting.
