function SynthesizeallImageConsMoments(solution_storage_full_path, I_syn_storage_full_path, ...
    set_spatial_correlation_flag, set_fixed_skewness_flag, sample_flag, skewness_fold, solving_method,moments_calculation_method)

N = 8;
K = 4;
image_source_full_path = 'D:\Natural_Scene_Simu\image\statiche0\FWHM25';

if set_spatial_correlation_flag
    mean_spatial_correlation_full_path = 'D:\Natural_Scene_Simu\image\statiche0syn_\FWHM25\spatial_corr.mat';
end


if ~exist(solution_storage_full_path, 'dir')
    mkdir(solution_storage_full_path);
end
if ~exist(I_syn_storage_full_path,'dir')
    mkdir(I_syn_storage_full_path)
end

%% whether to set the skewness to be a fixed value for all situation. will be very hard? give it a try.

%% load mean autocorrelation.
if set_spatial_correlation_flag
    auto_thresh = 0.2;
    load(mean_spatial_correlation_full_path);
    [correlation_true_prefixed, resolution_n_pixel_prefixed]  = MaxEntDis_Utils_FindCorrTrue(spatial_corr_mean, auto_thresh, K);
else
    correlation_true_prefixed = [];
    resolution_n_pixel_prefixed = [];
end

if set_fixed_skewness_flag
    skewness_prefiexed = 1;
else
    skewness_prefiexed = [];
end

%% loop over images.
imageDataInfo  = dir(fullfile(image_source_full_path, '*.mat'));
imageIDBank = 1:1:length(imageDataInfo);
n_image = length(imageIDBank);

%%
%% one image, get solution, save it.
time_for_each_image = cell(n_image, 1);
num_images_in_one_batch = 8;
num_batch = ceil(n_image/num_images_in_one_batch);
disp()
for nn = 1:num_batch
    image_range = (nn - 1) * num_images_in_one_batch + 1 : min([nn * num_images_in_one_batch, n_image]);
    imageDataInfo( image_range).name
    med_per_batch = cell(num_images_in_one_batch, 1);
    time_for_each_image_per_batch = cell(num_images_in_one_batch, 1);
    I_syn_per_batch = cell(num_images_in_one_batch, 1);
    disp(nn)
    tic
    parfor ii = 1:1:length(image_range)
        image_file_num = image_range(ii);
        
        %% first, load one image.
        image_file_this = fullfile(image_source_full_path, imageDataInfo(image_file_num).name);
        I_this = load(image_file_this);
        
        %% calculate data for that image.
        [med_per_batch{ii},time_for_each_image_per_batch{ii}, I_syn_per_batch{ii}] = ...
            MED_FindSolutionForEachImage_ConsMoments(I_this.I, 'sample_flag', sample_flag,'skewness_fold', skewness_fold,...
            'set_spatial_correlation_flag',set_spatial_correlation_flag,...
            'correlation_true_prefixed',correlation_true_prefixed,...
            'resolution_n_pixel_prefixed', resolution_n_pixel_prefixed, ...
            'set_fixed_skewness_flag', set_fixed_skewness_flag,...
            'skewness_prefiexed',skewness_prefiexed,'solving_method', solving_method,'moments_calculation_method',moments_calculation_method);
        
    end
    toc
    
    for ii = 1:1:length(image_range)
        image_file_num = image_range(ii);
        solved_file_this = fullfile(solution_storage_full_path, imageDataInfo(image_file_num).name);
        med = med_per_batch{ii};
        save(solved_file_this,  'med');
        time_for_each_image{image_file_num} = time_for_each_image_per_batch{ii};
        
        I_syn_file_this = fullfile(I_syn_storage_full_path, imageDataInfo(image_file_num).name);
        I =  I_syn_per_batch{ii};
        save(I_syn_file_this, 'I');
        
    end
end
