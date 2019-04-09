function Generate_VisualStim_And_VelEstimation_OneRowAllPhaseAllVel(image_process_info,image,stim,velocity,time, kernel, vel_range_bank, varargin)

synthetic_flag = false;
synthetic_type = [];

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
n_hor = 927; % how many data sets do you want?
nStim = 1000;
n_vel = length(vel_range_bank);
S = GetSystemConfiguration;
% path for the preprocessed image.
image_source_relative_path =  NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source', 'synthetic_flag',synthetic_flag);
image_source_full_path = fullfile(S.natural_scene_simulation_path, 'image', image_source_relative_path);

% path for the storage of the velocity.

synthetic_type = 'ns_all_phase';
visual_stimulus_relative_path = synthetic_type;
visual_stimulus_full_path_ns = fullfile(S.natural_scene_simulation_path, 'visual_stimulus', visual_stimulus_relative_path);
synthetic_type = 'sc_scramble_phase';
visual_stimulus_relative_path = synthetic_type;
visual_stimulus_full_path_sc = fullfile(S.natural_scene_simulation_path, 'visual_stimulus', visual_stimulus_relative_path);

% load the preprocessed data.
imageDataInfo  = dir(fullfile(image_source_full_path, '*.mat'));
nVerPixel = image.param.ver.nPixel;
imageIDBank = 1:1:length(imageDataInfo);
% imageIDBank(imageOutlier) = [];
nImage = length(imageIDBank);
nSpI = ChoseImage(nImage, nStim); % every image has particular number of stimulus. uniformly sample from different images.
imageSequence = randperm(nImage);

%%
v2_ns = zeros(n_hor, n_vel, nStim);
v2_sc = zeros(n_hor, n_vel, nStim);
v_real_all = zeros(n_hor, n_vel, nStim);
% if strcmp(which_kernel_type, 'reverse_correlation_sameKernel')
%     v3_ns = zeros(n_hor, n_vel, nStim);
%     v3_sc = zeros(n_hor, n_vel, nStim);
% end
sample_counter = 1;

for m = 1:1:nImage % 5 rows. not sure.
    % first image could be
    
    imageID = imageSequence(m);
    I = LoadProcessedImage(imageID,imageDataInfo,image_source_full_path);
    for k = 1:1:nSpI(imageID);
        % determine whether to flip the picture, balance the left and right.
        % posRow is the position of a randomly choosed row.
        % vel is a random velocity drawn from targeted distribution.
        % stim is a xt plot.spatial resolution is .38degree/pixel
        flip_flag = rand > 0.5;
        
        if flip_flag
            I = fliplr(I);
        end
        row_pos = randi(nVerPixel);
        oneRow = I(row_pos,:);
        oneRow_scrambled = Generate_VisualStim_And_VelEstimation_Utils_ScramblePhase(oneRow);
        for vv = 1:1:length(vel_range_bank)
            v_real = vel_range_bank(vv);
            stim_ns_full = VisualStimulusGeneration_Utils_CreateXT(oneRow, v_real, time, image);
            stim_sc_full = VisualStimulusGeneration_Utils_CreateXT(oneRow_scrambled, v_real, time, image);
            
            switch which_kernel_type
                case 'reverse_correlation_sameKernel'
                    v_est_ns_all = VelocityEstimation_OneStim_InputIsOneRow_v2_only(stim_ns_full, kernel);
                    v_est_sc_all = VelocityEstimation_OneStim_InputIsOneRow_v2_only(stim_sc_full, kernel);
                case 'HRC'
                    v_est_ns_all = VelocityEstimation_OneStim_InputIsOneRow_v2_only(stim_ns_full, kernel,'which_kernel_type',which_kernel_type);
                    v_est_sc_all = VelocityEstimation_OneStim_InputIsOneRow_v2_only(stim_sc_full, kernel,'which_kernel_type',which_kernel_type);
                case 'STE'
                    v_est_ns_all = VelocityEstimation_OneStim_InputIsOneRow_v2_only(stim_ns_full, kernel,'which_kernel_type',which_kernel_type);
                    v_est_sc_all = VelocityEstimation_OneStim_InputIsOneRow_v2_only(stim_sc_full, kernel,'which_kernel_type',which_kernel_type);
            end
            
            v2_ns(:,vv,sample_counter) = v_est_ns_all.v2;
            v2_sc(:,vv,sample_counter) = v_est_sc_all.v2;
            v_real_all(:,vv, sample_counter) = v_real;
        end
        sample_counter = sample_counter + 1;
    end
end
unit_name = sprintf('unit_%s', datestr(now,'mm_dd_HH_MM_SS'));
storage_full_path_ns = fullfile(visual_stimulus_full_path_ns, unit_name);
if ~exist(visual_stimulus_full_path_ns, 'dir')
    mkdir(visual_stimulus_full_path_ns)
end

v2 = v2_ns; v_real = v_real_all;
save(storage_full_path_ns, 'v2','v_real'); clear v2
%         data_storage_unit = data_storage_unit_ns;
%         save(storage_full_path_ns, 'data_storage_unit'); clear data_storage_unit

storage_full_path_sc = fullfile(visual_stimulus_full_path_sc, unit_name);
if ~exist(visual_stimulus_full_path_sc, 'dir')
    mkdir(visual_stimulus_full_path_sc)
end
v2 = v2_sc;
save(storage_full_path_sc, 'v2','v_real'); clear v2

end