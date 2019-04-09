function HRC_Contrast_Adaptation_Data_Generation_Gau(contrast_adaptation_flag_bank, adaptation_form_bank)
FWHM = 25;
kernel_extraction_method = 'HRC';
velocity.distribution = 'gaussian';
velocity.range = 100;
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
n_total_velocity = 200;
n_total_image = 1000;

%% load different HRC.
for ii = 1:1:length(adaptation_form_bank)
    adaptation_form = adaptation_form_bank{ii};
    contrast_adaptation_flag = contrast_adaptation_flag_bank(ii);
    kernel = GenerateHRC_ContrastAdaptation(contrast_adaptation_flag, adaptation_form);
    
    Generate_VisualStim_And_VelEstimation_WithinScene_Gau_HRC...
        (image_process_info,image,velocity,time, kernel,...
        'synthetic_flag_bank',synthetic_flag_bank,'synthetic_type_bank',synthetic_type_bank,'n_total_velocity', n_total_velocity,...
        'n_total_image', n_total_image);

    file_save_folder = ['D:\Natural_Scene_Simu\HRC_',adaptation_form,'_LNL'];
    if  ~exist(file_save_folder, 'dir')
        mkdir(file_save_folder);
    end
    movefile('D:\Natural_Scene_Simu\visual_stimulus',   file_save_folder);
end
%% move data into somewhere...
end