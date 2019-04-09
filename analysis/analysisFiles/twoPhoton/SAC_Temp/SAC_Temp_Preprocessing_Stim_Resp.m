function [r, stim, f] = SAC_Temp_Preprocessing_Stim_Resp(filename,bin_stim_flag, down_sample_response_flag)

load(filename);
% also load the stim data file.
load('D:\data_sac\stim_data.mat');

%% use frameis and stim_data to create stim.
% generate stim from stim data.
stim = zeros(length(r), 10);
for ii = 1:1:length(frameis) - 1
    idx = frameis(ii):frameis(ii + 1) - 1;
    stim(idx,:) = repmat(stim_data_0_center(ii,:), length(idx), 1);
end
%%


f = 1000;
if bin_stim_flag
    size_each_bin = 2;
    stim = SAC_Temp_BinStimulus(stim, size_each_bin);
end

nMultiBars = size(stim, 2);
if down_sample_response_flag
    resp_375Hz = zeros(length(frameis), 1);
    stim_375Hz = zeros(length(frameis), nMultiBars);
    for ii = 1:1:length(frameis) - 1
        resp_375Hz(ii) = sum(r(frameis(ii): frameis(ii + 1) - 1));
        stim_375Hz(ii,:) = stim(frameis(ii),:);
    end
    r = resp_375Hz;
    stim = stim_375Hz;
    f = 37.5;
end

end