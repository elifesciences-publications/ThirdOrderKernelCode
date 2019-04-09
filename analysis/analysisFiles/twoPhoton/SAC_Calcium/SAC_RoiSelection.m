function [L, mean_f] = SAC_RoiSelection(respfolder, varargin)

selection_method = 'water_shed';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


data_info = dir(fullfile(respfolder,'oim*.mat'));
n_data = length(data_info);
mean_movie = cell(n_data, 1);
nlines = 127;
for ii = 1:1:n_data
    file = fullfile(respfolder, data_info(ii).name);
    [~, movie] = SAC_utils_load_raw_movie(file);
    mean_movie{ii} = mean(movie(1:nlines, :, :), 3);
end
mean_f = mean(cat(3, mean_movie{:}), 3);
I = mean_f./max(mean_f(:));

if strcmp(selection_method, 'water_shed')
    L = SAC_RoiSelection_WaterShed(I);
elseif  strcmp(selection_method, 'background')
    fractionCutOff = 1;
    threshold = prctile(I(:),fractionCutOff);
    L = I < threshold;
    show_roi_mask(I, L);
end
L = cat(1, L, zeros(1, size(L, 2)));
end