
function Synthetic_NS_Utils_CalculateFFT(n_image_use, FWHM, varargin)
% n_image_use = 20;
save_data_flag  = false;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
image_process_info.contrast = 'static';
image_process_info.he = 0;
velocity.distribution = [];
velocity.range = 0;
image_process_info.FWHM = FWHM;

S = GetSystemConfiguration;

image_source_relative_path =  NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source');
image_source_full_path = fullfile(S.natural_scene_simulation_path, 'image', image_source_relative_path);


nImage = 421;
imageSequence = randperm(nImage);
image_use = imageSequence(1:n_image_use);

%% power spectrum



%% you should use NFFT = 927;
NFFT = 927;
Fs = 927/360; % how many points in degree.
F_ = ((0:1/NFFT:1-1/NFFT)*Fs).';

fft_mag_this = [];
for ii = 1:1:n_image_use
    % load the preprocessed data.
    imageDataInfo  = dir(fullfile(image_source_full_path, '*.mat'));
    I = LoadProcessedImage(image_use(ii) ,imageDataInfo,image_source_full_path);
    for rr = 1:1: size(I,1)
        one_row = I(rr, :);
        Y_ = fft(one_row(1: NFFT),  NFFT);
        Y_mag = abs(Y_);
        fft_mag_this = cat(1, fft_mag_this, Y_mag);        
    end
end

fft_mag_mean = mean(fft_mag_this, 1);

%%
if save_data_flag
    synthetic_flag = true;
    synthetic_str = [];
    filefullname = 'spatial_corr';
    image_source_relative_path =  NS_Filema_Param_To_FolderName(velocity, image_process_info, [],'folder_use','image_source','synthetic_flag',synthetic_flag);
    image_source_full_path = fullfile(S.natural_scene_simulation_path, 'image', image_source_relative_path);
    
    %     % compute distribution
    fft_mag = fft_mag_mean;
    if ~exist(image_source_full_path)
        mkdir(image_source_full_path);
    end
    filefullpath = fullfile(image_source_full_path, filefullname);
    save(filefullpath,'fft_mag');
end
end

