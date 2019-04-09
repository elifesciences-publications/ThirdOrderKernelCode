function [v2, v3, v_real] = Generate_VisualStim_And_VelEstimation_Gau_GiveScene...
    (scene_stim, vel_sequence, col_pos_sequence, file_name, varargin)
image = ParameterFile_ImageMetaInfo();
time = ParameterFile_TimeInfomation(1/60 * (64 - 1));
kernel_extraction_method = 'reverse_correlation';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% This file is for guassian.
% path for storage.
kernel = Load_Kernel_For_NS(0 , [], kernel_extraction_method);
n_scene = size(scene_stim, 1);
% for one skewness or one
v2_different_types = zeros(53,n_scene);
v3_different_types = zeros(53,n_scene);
v_real_all = vel_sequence;
for ii = 1:1:n_scene
    v_real = vel_sequence(ii);
    stim_full = VisualStimulusGeneration_Utils_CreateXT(scene_stim(ii,:), v_real, time, image);
    column_pos_reference = col_pos_sequence(ii);
    column_pos = VelocityEstimation_SelectPos(column_pos_reference);
    stim = stim_full(:, column_pos);
    switch kernel_extraction_method
        case 'reverse_correlation'
            vest = VelocityEstimation_OneStim(stim, kernel);
            v2_different_types(:,ii)= vest.v2;
            v3_different_types(:,ii)= vest.v3;
        case 'HRC'
            v2_different_types(:, ii) =  VelocityEstimation_OneStim_HRC(stim, kernel);
            %plot_scatter_plot_correlation_one_situation(data_this , 'matlab_debug','plot_flag', true);
    end
    v_real_all(ii) =  v_real;
end
%% data storage.
visual_stimulus_full_path = 'D:\Natural_Scene_Simu\visual_stimulus\gaussian114';
storage_full_path = fullfile(visual_stimulus_full_path, file_name);
if ~exist(visual_stimulus_full_path, 'dir')
    mkdir(visual_stimulus_full_path)
end
v2 = v2_different_types;
v3 = v3_different_types;
v_real = v_real_all;
% have a unifying storage format.
vest.v2 = v2;
vest.v3 = v3;
data_storage_unit.vest = vest;
data_storage_unit.v_real = v_real;
save(storage_full_path, 'data_storage_unit');
end