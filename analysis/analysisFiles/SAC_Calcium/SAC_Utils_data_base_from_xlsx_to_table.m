function SAC_Utils_data_base_from_xlsx_to_table()
S = GetSystemConfiguration;
sac_data_file = fullfile(S.sac_data_path, 'stim_info','Clark1_5_data_index.xlsx');
T = readtable(sac_data_file);

stimSet = {'ApparentMotion', 'Scintillator', 'Sinewave','Opponency', 'Scintillator_2019_03_26'};
clarkSet = {'Clark1', 'Clark2','Clark3', 'Clark4', 'Clark5'};
number = [1,2,3,4,5];
stim_to_clark = containers.Map(stimSet,clarkSet);
stim_to_number = containers.Map(stimSet,number);
clark_to_stim = containers.Map(clarkSet,number);

%
cell_name = cellfun(@(x, y) [x, '_', y], T.file_prefix, T.file_suffix , 'UniformOutput', false);
number = cellfun(@(x) clark_to_stim(x), T.stim);
T_cell_to_stim = table(cell_name, number);

save('data_base' ,'T_cell_to_stim', 'stim_to_number');