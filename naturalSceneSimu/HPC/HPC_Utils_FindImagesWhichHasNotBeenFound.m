function [miss_files, miss_files_info] = HPC_Utils_FindImagesWhichHasNotBeenFound(image_check_path)
%% list of files...
% image_check_path = 'statiche0syn_med_i_sc_iskew_solution_dis_mom'; % checked
% image_check_path = 'statiche0syn_med_i_sc_iskew_dis_mom'; % checked
% image_check_path = 'statiche0syn_med_i_sc_ivar_new_solution_dis_mom'; % checked
% image_check_path = 'statiche0syn_med_i_sc_ivar_solution_dis_mom'; 

% image_check_path = 'statiche0syn_med_i_sc_iskew_2_solution_dis_mom';
% image_check_path = 'statiche0syn_med_i_sc_iskew_05_solution_dis_mom';
% image_check_path = 'statiche0syn_med_i_sc_fiexedskew_solution_dis_mom';
% image_check_path = 'statiche0syn_med_m_sc_iskew_solution_dis_mom'; % Checked.
S = GetSystemConfiguration;
image_source_fullpath = fullfile(S.natural_scene_simulation_path, 'image','statiche0','FWHM25');
image_check_fullpath = fullfile(S.natural_scene_simulation_path, 'image',image_check_path,'FWHM25');

image_info = dir(fullfile(image_source_fullpath, '*.mat'));
n_image = length(image_info);
missed_file_flag = zeros(n_image, 1);
for ii = 1:1:n_image
    find_file = exist(fullfile(image_check_fullpath, num2str(image_info(ii).name)),'file');
    if find_file ~= 2
        missed_file_flag(ii) = 1;
    end
end
miss_files = find( missed_file_flag');
miss_files_info = image_info(miss_files);

% 71,105,178,239,277,308,309,327,345,363,367,370,372,393,394,401,402,404,407,413
% 
% 60,71,96,97,101,105,238,239,277,327,339,345,367,370,372,393,394,397,400,401,402,404,411


