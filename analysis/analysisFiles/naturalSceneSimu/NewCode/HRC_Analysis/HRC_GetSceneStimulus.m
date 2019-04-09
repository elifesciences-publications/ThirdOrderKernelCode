function scene_stim = HRC_GetSceneStimulus(n_total_image, synthetic_flag_bank, synthetic_type_bank)
FWHM = 25;
%% do you want to use binary, or use 114? interesting question. binary velocity first.
image_process_info.contrast = 'static';
image_process_info.he = 0;
image_process_info.FWHM = FWHM;
image_process_info.tf_tau = [];
% 

%%
scene_stim = Generate_VisStimVelEst_Utils_GetStim(image_process_info,'synthetic_flag_bank',synthetic_flag_bank,'synthetic_type_bank',synthetic_type_bank,'n_total_image', n_total_image);
end