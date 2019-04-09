function MaxEntDis_Wrap_FromConditionToVelocity(n_highest_moments, solution_path, I_syn_path, I_syn_selective_path, synthetic_type_bank)
generate_MED_solu_flag = 0;
sample_selective_image_flag = 1;
calculate_kernel_output_flag = 1;
%%
set_spatial_correlation_flag = false;
set_fixed_skewness_flag = false;
skewness_fold = 1;
solving_method = 'minimize_potential';
moments_calculation_method = 'discretization_distribution';

N = 512;
symmetrize_flag = 0; % symmetrize.
lower_bound_flag = 0;
K = 1;
zero_mean_flag = 1;

prefixed_gray_value_flag = 1;
prefixed_gray_value = linspace(-2.5,2.5, N);

%%
sample_flag = 1;
%%
S = GetSystemConfiguration;
solution_storage_full_path = fullfile(S.natural_scene_simulation_path, 'image',solution_path,'FWHM25');
I_syn_storage_full_path = fullfile(S.natural_scene_simulation_path, 'image',I_syn_path,'FWHM25');


if generate_MED_solu_flag
    parfor image_id = 1:1:421
        SynthesizeallImageConsMoments_OneImage(solution_storage_full_path, I_syn_storage_full_path, ...
            set_spatial_correlation_flag, set_fixed_skewness_flag, sample_flag, skewness_fold, ...
            solving_method,moments_calculation_method, n_highest_moments, N, symmetrize_flag, image_id, K,...
            zero_mean_flag, 0, lower_bound_flag,...
            prefixed_gray_value_flag, prefixed_gray_value)
    end
end
%% also sample it.
if sample_selective_image_flag
    GenerateImageFromSolution_Selective(solution_path, I_syn_selective_path,'n_highest_moments', n_highest_moments);
end

%% get the characterization

%% get the velocity data.
if calculate_kernel_output_flag
    
    synthetic_flag_bank = [1];
    which_file_to_use_bank = [1,2,3,4];
    parfor ii = 1:1:4
        which_file_to_use = which_file_to_use_bank(ii);
        mean_subtraction_onerow_flag = 1;
        CodeFormation_GenerateMotionEstimationData(which_file_to_use, synthetic_flag_bank, synthetic_type_bank, 114,...
            'mean_subtraction_onerow_flag',mean_subtraction_onerow_flag);
    end
end

end