function resp = SAC_GetResponse_OneFile(cell_name, suffix)
% dfoverf_method = 'last_frame';

respfolder = fullfile('D:\data_sac_calcium\', cell_name, 'saved_analysis',['resp_',suffix,'.mat']);
load(respfolder)
resp = preprocess.resp;
end
