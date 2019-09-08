function GenerateImageFromSolution_Selective(solution_path, I_syn_path, varargin)
n_highest_moments = 3;
zero_mean_flag = 1;
max_count = 150;

resolution_n_pixel_fold_flag = 0;
resolution_n_pixel_fold = 1;
resolution_n_pixel_fixed_flag = 0;
resolution_n_pixel_fixed = [];
lower_bound_flag = 0;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
S = GetSystemConfiguration;
solution_storage_full_path = fullfile(S.natural_scene_simulation_path, 'image',solution_path,'FWHM25');
I_syn_storage_full_path = fullfile(S.natural_scene_simulation_path, 'image',I_syn_path,'FWHM25');
if ~exist(I_syn_storage_full_path, 'dir')
    mkdir(I_syn_storage_full_path)
end
%% loop over images.
imageDataInfo  = dir(fullfile(solution_storage_full_path, '*.mat'));
imageIDBank = 1:1:length(imageDataInfo);
n_image = length(imageIDBank);

%% one image, get solution, save it.
num_images_in_one_batch = 8;
num_batch = ceil(n_image/num_images_in_one_batch);
for nn = 1:num_batch
    image_range = (nn - 1) * num_images_in_one_batch + 1 : min([nn * num_images_in_one_batch, n_image]);
    imageDataInfo( image_range).name;
    I_syn_per_batch = cell(num_images_in_one_batch, 1);
    tic
    for ii = 1:1:length(image_range)
        image_file_num = image_range(ii);
        %% first, load one image.
        solution_file_this = fullfile(solution_storage_full_path, imageDataInfo(image_file_num).name);
        med_solution_this_image = load(solution_file_this);
        n_row = length(med_solution_this_image.med);
        %% load solution
        I_syn = zeros( n_row, 927);
        parfor rr = 1:1:n_row
            med_this = med_solution_this_image.med(rr);
            %%
            flag = false; count = 1;
            while (~flag) && (count < max_count)
                resolution_n_pixel_usd = med_this.resolution_n_pixel;
                if resolution_n_pixel_fold_flag
                    resolution_n_pixel_usd = ceil(resolution_n_pixel_usd * resolution_n_pixel_fold);
                end
                if resolution_n_pixel_fixed_flag
                    resolution_n_pixel_usd = resolution_n_pixel_fixed;
                end
                
                [I_syn_this,I_syn_this_ori, ~]  ...
                    = MaxEntDist_ConsMoments_Utils_Sampling_OneScene(med_this.x_solved, med_this.gray_value, med_this.N, med_this.K, resolution_n_pixel_usd, ...
                    'n_highest_moments',n_highest_moments ,'plot_flag', false, 'lower_bound_flag', lower_bound_flag);
                
                data_sample_short_ori = compute_image_statistics_onerow_moments_correlation(I_syn_this_ori','prefixed_discretization_flag', 1,...
                    'upsample_flag',0,'N', med_this.N, 'K', med_this.K, 'med',med_this,'zero_mean_flag',zero_mean_flag, 'lower_bound_flag', lower_bound_flag);
                data_solution = compute_solution_statistics_onerow_moments_correlation(med_this, n_highest_moments);
                
                if abs(data_sample_short_ori(3) - data_solution(3)) < max(abs(data_solution(3) * 0.2), 0.1)
                    flag = 1;
                end
                count  = count + 1;
                %% if and only if all them is 10%
            end
            I_syn(rr, :) = I_syn_this;
            if count == max_count
                disp(['image : ',num2str(image_file_num ), 'row : ', num2str(rr)]);
            end
        end
        %% load the solution and sample from there. great idea.
        I_syn_per_batch{ii} = I_syn;
        
    end
    toc
    
    for ii = 1:1:length(image_range)
        image_file_num = image_range(ii);
        I_syn_file_this = fullfile(I_syn_storage_full_path, imageDataInfo(image_file_num).name);
        I =  I_syn_per_batch{ii};
        save(I_syn_file_this, 'I');
        
    end
end
