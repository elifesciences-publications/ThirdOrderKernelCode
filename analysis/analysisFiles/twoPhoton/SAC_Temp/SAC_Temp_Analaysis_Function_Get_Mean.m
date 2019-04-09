function  [data_each_noise_mat, data_mean] = SAC_Temp_Analaysis_Function_Get_Mean(file_path_all, kernel_identifier, kernel_to_get_string, data_info)
% cov_mat_noise will be too large to show
nfile = length(file_path_all);
% n_noise = 100; % hard coded.
% this maintain the information which is good.
if strfind(kernel_to_get_string, 'noise')
    n_noise = 100;
else
    n_noise = 1;
end

data_mean = cell(n_noise, 1); % several cell type...
data_each_noise = cell(n_noise, 1);
for nn = 1:1:n_noise
    data_each_noise{nn} = cell(nfile, 1);
end

for ff = 1:1:nfile
    % for one particular fly
    filepath = file_path_all{ff};
    data = SAC_Temp_Analysis_Function_Temp_Kernel_Extraction(filepath, kernel_identifier,kernel_to_get_string);
    for nn = 1:1:n_noise
        data_each_noise{nn}{ff} = data{nn};
    end
end % this step takes some time, how to optimize it?

data_each_noise_mat = cell(n_noise, 1);
for nn = 1:1:n_noise
    data_this_shuffle = data_each_noise{nn};
    data_each_noise_mat{nn} = cat(1,data_this_shuffle(:)); % change to matrix in one noise.
end

%% organize into mean kernel.
type_str = {'OnECI', 'OnV','OffECI', 'OffV'};
n_type = length(type_str);
for nn = 1:1:n_noise
    data_mean{nn} = cell(n_type,1);
    for tt = 1:1:n_type
        ind_this_type = SAC_Temp_CellType(data_info, type_str{tt});
        data_this_type_cell_this_shuffle = data_each_noise_mat{nn}(ind_this_type); data_this_type_this_shuffle = cat(3, data_this_type_cell_this_shuffle{:});
        data_mean{nn}{tt} = mean(data_this_type_this_shuffle,3);
    end
end
