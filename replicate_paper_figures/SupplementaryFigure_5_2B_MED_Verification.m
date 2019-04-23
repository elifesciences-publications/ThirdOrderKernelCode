function SupplementaryFigure_5_2B_MED_Verification()

S = GetSystemConfiguration;
data_set_str_bank = {fullfile(S.natural_scene_simulation_path, '\med_verification\ivar_N32_symdist_mean'),...
                     fullfile(S.natural_scene_simulation_path, '\med_verification\iskew_N32_symdist_mean')};
for ii = 1:1:2
    n_highest_moments = 3;
    solution_path = [];
    data_set_str = data_set_str_bank{ii};
    
    syn_path = [];
    image_statistics_flag = 0;
    solution_statistics_flag = 0;
    syn_image_statistics_flag = 0;
    plot_image_vs_solution_moments_flag = 1;
    plot_image_vs_solution_moments_long_sample_flag = 0;
    plot_image_vs_syn_image_moments_flag = 0;
    plot_image_vs_syn_image_correlations_flag = 0;
    
    evaluate_current_solution(n_highest_moments, solution_path, syn_path, data_set_str, ...
        image_statistics_flag, solution_statistics_flag, syn_image_statistics_flag,...
        plot_image_vs_solution_moments_flag, plot_image_vs_solution_moments_long_sample_flag,...
        plot_image_vs_syn_image_moments_flag,plot_image_vs_syn_image_correlations_flag)
end
end