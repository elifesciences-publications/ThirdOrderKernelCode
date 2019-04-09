function SAC_PreProcess_5D_Movie(cell_name, varargin)

fs = 15.6250;
selection_method = 'water_shed';

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
S = GetSystemConfiguration;
respfolder = fullfile(S.sac_data_path, cell_name);

%% roi selection
[L, mean_movie] = SAC_RoiSelection(respfolder, 'selection_method',selection_method);

%% get roi time traces..
data_info = dir(fullfile(respfolder,'oim*.mat')); 
n_data = length(data_info);
% oim 1 means stimulus 1...
% oim 2 means stimulus 2...
% oim 3 means stimulus 3...
data_info_name = arrayfun(@(tt) ['oim', num2str(tt),'_' cell_name, '.mat'], 1:n_data, 'UniformOutput', false);
movie_used = cell(n_data, 1);
for tt = 1:1:n_data
    file = fullfile(respfolder, data_info_name{tt});
    [~, movie_used{tt}] = SAC_utils_load_raw_movie_5D_movie(file);
end
resp_f = SAC_GetRoiTimeTrace_5D_movie(L, movie_used);

%% get dfoverf.
dfoverf_method = 'last_frame';
dfoverf = filterRoiTrace_calculate_dfoverf(dfoverf_method, resp_f);

%% save file
file_dir = fullfile(respfolder,'saved_analysis');
if ~exist(file_dir,'dir')
    mkdir(file_dir);
end
if strcmp(selection_method, 'background')
    file_path = fullfile(file_dir, ['resp_background.mat']);
else
    file_path = fullfile(file_dir, ['resp_',dfoverf_method,'.mat']);
end

preprocess.resp = dfoverf;
preprocess.stim = 1:n_data; % not useful
preprocess.roi_mast = L;
preprocess.meanfilm = mean_movie;
preprocess.dfoverf_method = dfoverf_method;
preprocess.dim = ['time','trial','epoch','rois'];
save(file_path, 'preprocess');

%% also save the corresponding mean movie
end