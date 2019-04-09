function resp = SAC_GetResponse_OneStim(stim_name, varargin) %% now just averaging over trials, over roi and over cells. report the standard deviation over recording. not over rois.
dfoverf_method = 'last_frame';
suffix = dfoverf_method;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
n_frames = 5;
stim_onset_frames = 15; 

cell_name_all = SAC_GetFiles_GivenStimulus(stim_name);
n_cell = length(cell_name_all);
resp = cell(n_cell, 1);
for nn = 1:1:n_cell
    data = SAC_GetResponse_OneFile(cell_name_all{nn}, suffix);
    resp{nn} = data - mean(data(stim_onset_frames - n_frames:stim_onset_frames, :,:,:), 1);
end

end