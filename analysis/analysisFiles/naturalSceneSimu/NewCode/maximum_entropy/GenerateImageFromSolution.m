function GenerateImageFromSolution(solution_path, I_syn_path, varargin)
n_highest_moments = 3;
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
    imageDataInfo( image_range).name
    I_syn_per_batch = cell(num_images_in_one_batch, 1);
    tic
    parfor ii = 1:1:length(image_range)
        image_file_num = image_range(ii);
        %% first, load one image.
        solution_file_this = fullfile(solution_storage_full_path, imageDataInfo(image_file_num).name);
        med_solution_this_image = load(solution_file_this);
        n_row = length(med_solution_this_image.med);
        %% load solution
        I_syn = zeros( n_row, 927);
        for rr = 1:1:n_row
            med_this = med_solution_this_image.med(rr);
            [I_syn_this,~]  ...
                = MaxEntDist_ConsMoments_Utils_Sampling_OneScene(med_this.x_solved, med_this.gray_value, med_this.N, med_this.K, med_this.resolution_n_pixel, ...
                'n_highest_moments',n_highest_moments ,'plot_flag', false);
            I_syn(rr, :) = I_syn_this;
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
