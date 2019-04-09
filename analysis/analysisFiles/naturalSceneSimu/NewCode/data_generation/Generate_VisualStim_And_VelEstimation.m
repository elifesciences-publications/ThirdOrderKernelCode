function Generate_VisualStim_And_VelEstimation(image_process_info,image,stim,velocity,time, kernel, varargin)

synthetic_flag = false;
synthetic_type = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end



S = GetSystemConfiguration;
% path for the preprocessed image.
image_source_relative_path =  NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source', 'synthetic_flag',synthetic_flag);
image_source_full_path = fullfile(S.natural_scene_simulation_path, 'image', image_source_relative_path);

% path for the storage of the stimulus.
visual_stimulus_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','visual_stimulus','synthetic_flag',synthetic_flag,'synthetic_type',synthetic_type);
visual_stimulus_full_path = fullfile(S.natural_scene_simulation_path, 'visual_stimulus', visual_stimulus_relative_path);

if strcmp('dynamic',image_process_info.contrast) || strcmp('dynamic_both_future_and_past',image_process_info.contrast)
    contrast_filter = VisualStimulusGeneration_Utils_GenerateTempFilter(image_process_info.tf_tau);
end
% load the preprocessed data.
n_total_sample_points = stim.n_samplepoints;
nSpS = stim.nSps;

if synthetic_flag
    nImage = 1;
    nSpI = n_total_sample_points;
    imageSequence = 1;
    
else
    imageDataInfo  = dir(fullfile(image_source_full_path, '*.mat'));
    nVerPixel = image.param.ver.nPixel;
    imageIDBank = 1:1:length(imageDataInfo);
    % imageIDBank(imageOutlier) = [];
    nImage = length(imageIDBank);
    nSpI = ChoseImage(nImage,n_total_sample_points); % every image has particular number of stimulus. uniformly sample from different images.
    imageSequence = randperm(nImage);
end
%%
storage_unit_counter = 1; % storage_sample_unit_counter counts how many storage units data has been computed.
storage_sample_unit_counter = 1; % storage_sample_unit_counter counts how many data has been collected for this storage unit, when it reaches nSpS, the data will be stored into file
all_sample_unit_counter = 1; % counter counts how many data unit has been calculated. the name of the data will be determined by the final number of counter.

% initiliaze a sample counter.
% this should be a structure array...
data_struct = struct('image_ID', [],  'flip_flag', [], 'row_pos',[], 'column_pos', [], 'v_real', [], 'stim', [], 'v_est', []);
data_storage_struct = repmat(data_struct, [nSpS, 1]);
data_storage_unit = data_storage_struct;

for m = 1:1:nImage
    % first image could be
    if synthetic_flag
        img_distribution = LoadSynthticDistribution(image_source_full_path, synthetic_type);
        imageID = 1;
        row_pos = 1;
    else
        imageID = imageSequence(m);
        I = LoadProcessedImage(imageID,imageDataInfo,image_source_full_path);
    end
    for k = 1:1:nSpI(imageID);
        % determine whether to flip the picture, balance the left and right.
        % posRow is the position of a randomly choosed row.
        % vel is a random velocity drawn from targeted distribution.
        % stim is a xt plot.spatial resolution is .38degree/pixel
        flip_flag = rand > 0.5;
        if synthetic_flag
            switch synthetic_type
                case 'contrast_dist'
                    rand_ind = randperm(length(img_distribution));
                    oneRow = img_distribution(rand_ind(1:image.param.hor.nPixel));
                case 'spatial_corr'
                    oneRow =  Generate_VisualStim_Synthetic_Spatial_Corr(img_distribution);
                case 'med_sc_cd'
                    oneRow = Generate_VisualStim_Synthetic_MaxEntDis_MeanCS(img_distribution);
            end
        else
            if flip_flag
                I = fliplr(I);
            end
            row_pos = randi(nVerPixel);
            oneRow = I(row_pos,:);
        end
        
        v_real = VisualStimulusGeneration_Utils_SampleOneV(velocity);
        switch image_process_info.contrast
            case 'static'
                stim_full = VisualStimulusGeneration_Utils_CreateXT(oneRow, v_real, time, image);
                column_pos = VelocityEstimation_SelectPos(varargin{:});
                stim = stim_full(:, column_pos);
                
            case 'dynamic'
                [stim, column_pos] = VisualStimulusGeneration_Utils_CreateXT_Dyna_Con(oneRow, v_real, time, contrast_filter);
                
            case 'dynamic_both_future_and_past'
                [stim, column_pos] = VisualStimulusGeneration_Utils_CreateXT_Dyna_Con_BothSide(oneRow, v_real, time, contrast_filter);
                
        end
        v_est = VelocityEstimation_OneStim(stim, kernel);
        
        %% storage.
        
        data.image_ID = imageID;
        data.flip_flag = flip_flag;
        data.row_pos = row_pos;
        data.stim = stim;
        data.v_real = v_real;
        data.column_pos = column_pos;
        data.v_est = v_est;
        data_storage_unit(storage_sample_unit_counter) = data;
        
        if storage_sample_unit_counter == nSpS
            % save current data into the folder.
            unit_name = sprintf('unit_%s', datestr(now,'mm_dd_HH_MM_SS'));
            %
            storage_full_path = fullfile(visual_stimulus_full_path, unit_name);
            if ~exist(visual_stimulus_full_path, 'dir')
                mkdir(visual_stimulus_full_path)
            end
            save(storage_full_path, 'data_storage_unit');
            data_storage_unit =  data_storage_struct; % clear the old, start a new one.
            storage_sample_unit_counter = 0;
            storage_unit_counter = storage_unit_counter + 1;
        end
        
        storage_sample_unit_counter = storage_sample_unit_counter  + 1;
        all_sample_unit_counter = all_sample_unit_counter + 1;
    end
end
end