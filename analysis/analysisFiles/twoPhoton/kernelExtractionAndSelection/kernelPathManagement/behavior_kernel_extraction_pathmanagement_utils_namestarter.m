function kernel_name_starter = behavior_kernel_extraction_pathmanagement_utils_namestarter(process_stim_flag, FWHM)
if ~process_stim_flag
    kernel_name_starter = 'ori';
else
    kernel_name_starter = sprintf('FHMW%d', FWHM);
end
end