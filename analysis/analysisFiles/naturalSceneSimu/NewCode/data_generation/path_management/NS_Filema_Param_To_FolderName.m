function folder_relative_path = NS_Filema_Param_To_FolderName(velocity, image_process_info, velocity_estimation, varargin)
folder_use = [];
synthetic_flag = false;
synthetic_type = [];
raw_image_flag = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if synthetic_flag
    %     if strcmp(folder_use, 'image_source')
    %         img_folder = sprintf('%she%dsyn%s', image_process_info.contrast,image_process_info.he);
    %     else
    img_folder = sprintf('%she%dsyn_%s', image_process_info.contrast,image_process_info.he, synthetic_type); % no problem.
    %     end
elseif raw_image_flag
    img_folder = 'raw_image';
else
    img_folder = sprintf('%she%d', image_process_info.contrast,image_process_info.he);
end

switch image_process_info.contrast
    case 'static'
        mean_lum_scale_folder = sprintf('FWHM%d', image_process_info.FWHM);
    case 'dynamic'
        mean_lum_scale_folder = sprintf('Tau%d', round(image_process_info.tf_tau * 1000));
    case 'dynamic_both_future_and_past'
        mean_lum_scale_folder = sprintf('Tau%d', round(image_process_info.tf_tau * 1000));
end
% ave_over_space_folder = sprint('ave%d', vel_estimation.ave_over_space); % stimulus will be different? do you want then to share the same stimulus?
% this will only for calculating the
if ~raw_image_flag
    switch folder_use
        case 'image_source'
            switch image_process_info.contrast
                case 'static'
                    folder_relative_path = fullfile(img_folder, mean_lum_scale_folder);
                case 'dynamic'
                    folder_relative_path = fullfile(img_folder, '');
                case 'dynamic_both_future_and_past'
                    folder_relative_path = fullfile(img_folder, '');
                    
            end
        case 'visual_stimulus'
            vel_folder  = sprintf('%s%d', velocity.distribution, velocity.range);
            folder_relative_path = fullfile(img_folder, mean_lum_scale_folder, vel_folder);
            
        case 'velocity_estimation'
            vel_folder  = sprintf('%s%d', velocity.distribution, velocity.range);
            estimation_folder = sprintf('ave%d', velocity_estimation.space_range);
            folder_relative_path = fullfile(estimation_folder, img_folder, mean_lum_scale_folder, vel_folder);
    end
else
     folder_relative_path = img_folder;
end