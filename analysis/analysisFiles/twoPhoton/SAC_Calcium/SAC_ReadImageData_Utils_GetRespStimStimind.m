function [resp, resptime_perroi, stimtime, stimseq, roi_mask] = SAC_ReadImageData_Utils_GetRespStimStimind(cell_name, fpass)

%% load preprocessed data.
folder  = 'D:\data_sac_calcium';
respfolder = fullfile('D:\data_sac_calcium\', cell_name);
stimtime_file = fullfile(respfolder, [cell_name(5:end),'.mat']);
datainfo = dir(fullfile(folder, cell_name, [cell_name, '_preproc','_f',num2str(fpass * 100),'.mat']));
datafile = fullfile(folder, cell_name, datainfo.name);
data= load(datafile);

stimtime = data.stimtime;
roi_center = SAC_utils_cal_roi_center(data.roi_mask);
roi_mask = data.roi_mask;
%% response
resp = data.resp_dfoverf;
% resp_f = data.resp_f;
%% load resptime and stimseq.
resptime = SAC_Load_RespTime();
% for the simulation data, it is a bit different. The response is shorter.
if size(resp, 1) < size(resptime, 1) && contains(cell_name,'simu')
    resptime = resptime(end - size(resp, 1) + 1:end, :);
end

%% get the stimulus sequence, and th
stimseq = SAC_Load_StimSeq(stimtime_file);
nlines = 128;
resptime_perline = SAC_Timealign_frame2lin(resptime(:, 1), nlines);
resptime_perroi = resptime_perline(:, floor(roi_center(:, 1)));

end