function SAC_PreProcess_Main(cell_name, fpass)
%% This function is mainly used for receptive field analysis.
% SAC_PreProcess_5D_Movie is the main function for roi extraction and
% selection now.
bleed_through_flag = 1;
fs = 15.6250;

respfolder = fullfile('D:\data_sac_calcium\', cell_name);
stimtime_file = fullfile(respfolder, [cell_name(5:end),'.mat']);

%% roi selection
[L, mean_movie] = SAC_RoiSelection(respfolder);
%% bleedthrough_subtraction.
if bleed_through_flag
    movie_used = SAC_BleedThroughSubtraction_Main(respfolder, stimtime_file);
else
    data_info = dir(fullfile(respfolder,'oim*.mat'));
    n_data = length(data_info);
    movie_used = cell(n_data, 1);
    for tt = 1:1:n_data
        file = fullfile(respfolder, data_info(tt).name);
        [~, movie_used{tt}] = SAC_utils_load_raw_movie(file);
    end
end
%% get roi traces
resp_f = SAC_GetRoiTimeTrace(L, movie_used);

%% compute dfoverf with exponential
% resp_dfoverf = zeros(size(resp_f));
% f0 = zeros(size(resp_f));
% for tt = 1:1:size(resp_f, 3)
%      [resp_dfoverf(2:end,:,tt), f0(2:end,:,tt)] = filterRoiTraces_Utils_HighLowPassAndNormalize(resp_f(:,:,tt), fpass,fs);
% %     [resp_dfoverf(:,:,tt), ~] = filterRoiTraces_Utils_FitExpAndNormalize(resp_f(:,:,tt),resp_f(:,:,tt),1, size(resp_f, 1));
% end
[resp_dfoverf, f0] = filterRoiTraces_Utils_HighLowPassAndNormalize(resp_f, fpass,fs);
%% compute dfover with highpass lowpass


%% load stimtime, and store info into analysis_file.
stimtime = SAC_Load_Stimtime(stimtime_file);
roi_mask = L;
% analysis_file = fullfile(respfolder, [cell_name, '_preproc','_bl',num2str(bleed_through_flag),'.mat']);
analysis_file = fullfile(respfolder, [cell_name, '_preproc','_f',num2str(fpass * 100),'.mat']);
save(analysis_file, 'resp_dfoverf','resp_f', 'f0', 'stimtime', 'roi_mask', 'mean_movie');
end