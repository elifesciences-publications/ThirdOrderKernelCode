function  [data_set,  p_i] = FixVar_ChangeSkew_OneModel(gray_value, variance_value, solve_equation_flag, generate_data_flag, analyze_data_flag, plot_solution_flag)
%% first, calculate the solution for different variance

S =  GetSystemConfiguration;
storage_name = 'statiche0syn_med_fixvar_chaskew';
data_source = 'fixvar_chaskew\visual_stimulus';
p_i = [];
%% set 1
n_sample_points = 1000;
skewness_bank = [-2:0.5:2];
if solve_equation_flag
    NS_MED_FixVarianceChangeSkewness(gray_value, variance_value, skewness_bank, 'n_sample_points', n_sample_points,...
        'storage_name', storage_name);
end
n_condition = length(skewness_bank);


if generate_data_flag
    % %% third, motion estimation from it.
    n_total_velocity = n_sample_points;
    velocity.distribution = 'binary';
    velocity.range = 114;
    seed_num = 0;
    [vel_sequence, col_pos_sequence] = Generate_VisStimVelEst_Utils_WithinScene_GenVel(n_total_velocity,  velocity, 'seed_num', seed_num);
    
    %% load data.
    
    n_condition = length(skewness_bank);
    for ii = 1:1:n_condition
        %% differenet files.
        skew_this = skewness_bank(ii);
        if skew_this < 0
            skew_name = ['n', num2str(abs(skew_this) * 10)];
        else
            skew_name = ['p', num2str(abs(skew_this) * 10)];
        end
        name_for_this_variance_and_skew = ['v',num2str(variance_value  * 1000), 's', skew_name, '.mat'];
        scene_name = [storage_name,'_scene'];
        image_source_full_path = fullfile(S.natural_scene_simulation_path, 'image', scene_name, name_for_this_variance_and_skew);
        I_syn = load(image_source_full_path);
        tic
        Generate_VisualStim_And_VelEstimation_Gau_GiveScene...
            (I_syn.I, vel_sequence, col_pos_sequence,  name_for_this_variance_and_skew);
        toc
    end
    
    
end
if plot_solution_flag
    x_solved_ban = cell(n_condition, 1);
    for ii = 1:1:n_condition
        %% differenet files.
        skew_this = skewness_bank(ii);
        if skew_this < 0
            skew_name = ['n', num2str(abs(skew_this) * 10)];
        else
            skew_name = ['p', num2str(abs(skew_this) * 10)];
        end
        name_for_this_variance_and_skew = ['v',num2str(variance_value  * 1000), 's', skew_name, '.mat'];
        solution_name = [storage_name, '_solu'];
        solution_source_full_path = fullfile(S.natural_scene_simulation_path, 'image', solution_name, name_for_this_variance_and_skew);
        solu = load(solution_source_full_path);
        med = solu.med;
        mu_true = med.mu_true;
        cov_true = med.cov_true;
        n_highest_moments = 3;
        N = med.N;
        K = med.K;
        x_solved_bank{ii} = med.x_solved;
        % get med. plot gray value out?
    end
    
    %% plot it.
    p_i = zeros(N, K, n_condition);
    for ii = 1:1:n_condition
        [~, ~, p_i(:, :, ii)] = MaxEntDis_ConsMoments_Utils_PlotResult(x_solved_bank{ii}, gray_value, mu_true, cov_true, n_highest_moments, N, K);
    end
    
    %%
end
%% fourth,  analyze data...
if analyze_data_flag
    S =  GetSystemConfiguration;
    n_condition = length(skewness_bank);
    data_set = cell(n_condition, 1);
    for ii = 1:1:n_condition
        %% differenet files.
        skew_this = skewness_bank(ii);
        if skew_this < 0
            skew_name = ['n', num2str(abs(skew_this) * 10)];
        else
            skew_name = ['p', num2str(abs(skew_this) * 10)];
        end
        name_for_this_variance_and_skew = ['v',num2str(variance_value  * 1000), 's', skew_name, '.mat'];
        data_source_full_path = fullfile(S.natural_scene_simulation_path, data_source, name_for_this_variance_and_skew);
        data_this = load(data_source_full_path);
        data_this_.v2 = sum(data_this.v2, 1)';
        data_this_.v3 = sum(data_this.v3, 1)';
        data_this_.v_real = data_this.v_real;
        data_set{ii} = data_this_;
        
        %% calculate correlation...
    end
end


