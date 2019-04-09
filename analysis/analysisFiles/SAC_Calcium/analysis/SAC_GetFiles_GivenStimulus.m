function cell_name = SAC_GetFiles_GivenStimulus(stim_name)
    S = GetSystemConfiguration;
    sac_data_file = fullfile(S.sac_data_path, 'stim_info','data_base.mat');
    load(sac_data_file);
    
    X = stim_to_number(stim_name);
    cell_name = T_cell_to_stim.cell_name(T_cell_to_stim.number == X);
end