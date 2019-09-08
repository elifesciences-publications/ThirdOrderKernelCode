function  Generate_VisualStim_And_VelEstimation_GiveScene(scene_stim, file_name, velocity, varargin)
%% This will deal with Gaussian velcity and binary velocity at the same time.
%% col_pos_sequence will be the same length
seed_num = 0;
image = ParameterFile_ImageMetaInfo();
time = ParameterFile_TimeInfomation(1/60 * (64 - 1));
kernel_extraction_method = 'reverse_correlation';
spatial_range = 54;
storage_filename = 'preserve_2nd';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
S = GetSystemConfiguration;
visual_stimulus_full_path = fullfile(S.natural_scene_simulation_path, 'visual_stimulus',storage_filename);
%% This file is for guassian.
% path for storage.
if strcmp(kernel_extraction_method ,'spatial_corr')
        corr_name = {'Two Point DT 1','Converging DT 1'};
else
    kernel = Load_Kernel_For_NS(0 , [], kernel_extraction_method);
end
n_scene = size(scene_stim, 1);
% for one skewness or one
switch velocity.distribution
    %% you should have a velocity distribution.
    case 'gaussian'
        n_vel = 400;
        [vel_sequence, col_pos_sequence] = Generate_VisStimVelEst_Utils_WithinScene_GenVel(n_vel,  velocity, 'seed_num', 0); %% to be consistent with hrc_gaussian.
        %% 
    case 'binary'
        n_vel = length(velocity.range);
        [~, col_pos_sequence] = Generate_VisStimVelEst_Utils_WithinScene_GenVel(n_scene,  velocity, 'seed_num', seed_num);
        vel_sequence = velocity.range;        
end
v2_different_types = zeros(spatial_range - 1,n_vel,n_scene);
v3_different_types = zeros(spatial_range - 1,n_vel,n_scene);
v_real_all = zeros(n_vel, n_scene);
for ii = 1:1:n_scene
    for vv = 1:1:n_vel
%         switch velocity.distribution
%             case 'gaussian'
                v_real = vel_sequence(vv);
                v_real_all(vv, ii) = v_real;
%             case 'binary'
%                 v_real = vel_sequence(vv);
%                 v_real_all(vv, ii) = v_real;
%         end
        
        stim_full = VisualStimulusGeneration_Utils_CreateXT(scene_stim(ii,:), v_real, time, image);
        column_pos_reference = col_pos_sequence(vv);
        column_pos = VelocityEstimation_SelectPos(column_pos_reference);
        stim = stim_full(:, column_pos);
        switch kernel_extraction_method
            case 'reverse_correlation'
                vest = VelocityEstimation_OneStim(stim, kernel);
                v2_different_types(:,vv, ii)= vest.v2;
                v3_different_types(:,vv, ii)= vest.v3;
            case 'HRC'
                v2_different_types(:, vv, ii) =  VelocityEstimation_OneStim_HRC(stim, kernel);
            case 'STE'
%                 v2_different_types(:, vv, ii) = VelocityEstimation_OneStim_InputIsOneRow_STE(stim_full, kernel);
                v2 = VelocityEstimation_OneStim_InputIsOneRow_AllKernel(stim_full, kernel, 'which_kernel_type', 'STE');
                v2_different_types(:, vv, ii) = v2(column_pos(1:spatial_range - 1));
            case 'spatial_corr'
                data.stim = stim;
                data.column_pos = column_pos;
                stim_corr_this = NS_Statistics_Calculate_Corr_From_Data(data,'corr_name', corr_name);
                v2_different_types(:,vv, ii) = stim_corr_this(:, 1, 1) - stim_corr_this(:, 1, 2);
                v3_different_types(:,vv, ii) = stim_corr_this(:, 2, 1) - stim_corr_this(:, 2, 2);
        end
    end
    
end
%% data storage.
storage_full_path = fullfile(visual_stimulus_full_path, file_name);
if ~exist(visual_stimulus_full_path, 'dir')
    mkdir(visual_stimulus_full_path)
end
v2 = squeeze(v2_different_types);
v3 = squeeze(v3_different_types);
v_real = squeeze(v_real_all); % you might have to make 

save(storage_full_path, 'v2','v3','v_real');
end