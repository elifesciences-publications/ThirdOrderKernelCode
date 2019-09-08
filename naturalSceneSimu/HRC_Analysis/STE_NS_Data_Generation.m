function STE_NS_Data_Generation(kernel_extraction_method)
FWHM = 25;
% kernel_extraction_method = 'STE';
switch kernel_extraction_method
    case 'STE'
        kernel =  VelocityEstimation_Utils_GenerateSTE();
        file_save_folder = ['D:\Natural_Scene_Simu\STE_binary'];
    case 'HRC'
        kernel = VelocityEstimation_Utils_GenerateHRC();
        file_save_folder = ['D:\Natural_Scene_Simu\HRC_binary_dense'];

end

velocity.distribution = 'binary';
velocity.range = 0:10:1000;
%% do you want to use binary, or use 114? interesting question. binary velocity first.
image_process_info.contrast = 'static';
image_process_info.he = 0;
image_process_info.FWHM = FWHM;
image_process_info.tf_tau = [];

%%
image = ParameterFile_ImageMetaInfo();
time = ParameterFile_TimeInfomation(1/60 * (64 - 1));


synthetic_flag_bank = [false];
synthetic_type_bank = {[]};
n_total_velocity = 400;
n_total_image = 1000;
Generate_VisualStim_And_VelEstimation_WithinScene...
    (image_process_info,image,velocity,time, kernel,...
    'synthetic_flag_bank',synthetic_flag_bank,'synthetic_type_bank',synthetic_type_bank,'n_total_velocity', n_total_velocity,...
    'n_total_image', n_total_image,'kernel_extraction_method', kernel_extraction_method);

if  ~exist(file_save_folder, 'dir')
    mkdir(file_save_folder);
end
movefile('D:\Natural_Scene_Simu\visual_stimulus',   file_save_folder);

%% move data into somewhere...
end