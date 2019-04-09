function CodeFormation_GenerateMotionEstimationData(which_file_to_use, synthetic_flag_bank, synthetic_type_bank, velocity_range,varargin)
mean_subtraction_flag = 0;
kernel_extraction_method = 'reverse_correlation';

FWHM = 25;
mean_subtraction_onerow_flag = false;
mean_subtraction_vstim_flag = false;
contrast_mode = 'static';
tf_tau = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
force_new_image_selection_flag = false;
velocity.distribution = 'gaussian';
velocity.range = velocity_range;

image_process_info.contrast = contrast_mode;
image_process_info.he = 0;
image_process_info.FWHM = FWHM;
image_process_info.tf_tau = tf_tau;

kernel = Load_Kernel_For_NS(0 , [], kernel_extraction_method);

image = ParameterFile_ImageMetaInfo();
time = ParameterFile_TimeInfomation(1/60 * (64 - 1));
simulation_stim = ParameterFile_SimuSample(2000, 1000);

tic
Generate_VisualStim_And_VelEstimation_Syn_Main(image_process_info, image, simulation_stim, velocity, time, kernel,...
    'synthetic_flag_bank', synthetic_flag_bank, 'synthetic_type_bank', synthetic_type_bank, ...
    'force_new_image_selection_flag',force_new_image_selection_flag, 'which_file_to_use', which_file_to_use,...
    'mean_subtraction_flag',mean_subtraction_flag,'kernel_extraction_method',kernel_extraction_method,...
    'mean_subtraction_onerow_flag', mean_subtraction_onerow_flag, 'mean_subtraction_vstim_flag', mean_subtraction_vstim_flag);
toc
movefile D:\Natural_Scene_Simu\visual_stimulus D:\Natural_Scene_Simu\rc_match_up_row_mean_subtracted
%% move data into somewhere...
end