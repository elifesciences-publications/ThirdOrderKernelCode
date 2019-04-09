function ensemble_preserve_2nd_utils_generate_image_set(seed_num, n_sample, storage_folder, scene_name, use_all_flag)
n_hor = 927;
n_fft = floor((n_hor - 1)/2);

S =  GetSystemConfiguration;
img_folder = fullfile(S.natural_scene_simulation_path, 'image','statiche0','FWHM25');

%%
%% look at meta data.
% check whether has been calculated. If it is, load it directly.
if ~exist(storage_folder,'dir')
    mkdir(storage_folder);
end
savefile = fullfile(storage_folder, 'power.mat');
if exist(savefile ,'file')
    load(savefile);
else
    if use_all_flag
        [fn_power, ~] = ensemble_preserve_2nd_utils_2nd_stastics_all(img_folder, savefile);
    else
        data_sequence_image_421 = Generate_VisStimVelEst_Utils_GenerateImageSequence(n_sample, 'seed_num', seed_num);
        data_sequence_image = tansfer_data_sequence_421_to_vector(data_sequence_image_421);        
        [fn_power, ~] = ensemble_preserve_2nd_utils_2nd_stastics_selected(img_folder, data_sequence_image, savefile);

    end
end

%% sample in fourier domain.
rng(seed_num)
real_fft      = normrnd(0,1, [n_sample, n_fft]); %% This is wrong. what is the
imaginary_fft = normrnd(0,1,[n_sample, n_fft]);
real_fft      = real_fft .* sqrt(fn_power/2);
imaginary_fft = imaginary_fft .* sqrt(fn_power/2);

%% inverse fourier transformation
Y = [zeros(n_sample, 1), real_fft + 1i * imaginary_fft, real_fft(:, end:-1:1) - 1i * imaginary_fft(:, end:-1:1)];
I = ifft(Y, n_hor, 2, 'symmetric');
save(fullfile(storage_folder, scene_name),'I');
end
