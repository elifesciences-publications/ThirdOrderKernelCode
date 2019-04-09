
function Synthetic_NS_Utils_Calculate_ACF_PCF(n_image_use, FWHM, varargin)
% n_image_use = 20;
save_data_flag  = false;
n_spatial_points = 15; % large values.
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
constrast_different_dx = [];
for ii = 1:1:n_image_use
    % load the preprocessed data.
    imageDataInfo  = dir(fullfile(image_source_full_path, '*.mat'));
    I = LoadProcessedImage(image_use(ii) ,imageDataInfo,image_source_full_path);
    constrast_different_dx = zeros(numel(I), n_spatial_points);
    for jj = 1:1:n_spatial_points
        I_shift = circshift(I, -(jj - 1),2);
        I_shift = I_shift';
        constrast_different_dx(:, jj) = I_shift(:);
    end
end
spatial_acf_corr = zeros(n_spatial_points,1);
spatial_pacf_cor = zeros(n_spatial_points,1);
for jj = 1:1:n_spatial_points
    spatial_acf_corr(jj) = corr(constrast_different_dx(:,1),  constrast_different_dx(:,jj));
    spatial_pacf_cor(jj) = partialcorr(constrast_different_dx(:,1),  constrast_different_dx(:,jj), constrast_different_dx(:,2:jj - 1));
end

%% plot for acf and pcf.
MakeFigure;
subplot(2,1,1)
scatter(0:n_spatial_points - 1, spatial_acf_corr,'ro','filled');
hold on
for jj = 1:1:n_spatial_points
    plot([jj - 1, jj - 1], [0, spatial_acf_corr(jj)], 'r');
end
title('autocorrelation function');
xlabel('lag');
ConfAxis


subplot(2,1,2)
scatter(0:n_spatial_points - 1, spatial_pacf_cor,'ro','filled');
hold on
for jj = 1:1:n_spatial_points
    plot([jj - 1, jj - 1], [0, spatial_pacf_cor(jj)], 'r');
end
set(gca, 'XAxisLocation','origin')
xlabel('lag')
title('partial autocorrelation function');
ConfAxis
end