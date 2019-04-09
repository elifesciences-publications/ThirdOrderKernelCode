function SAC_SineWave_KF_Plot(resp, data_info, epoch_ID)
f_resp = 15.625;
on_set = ceil(f_resp);
off_set = floor(f_resp * 5 + on_set);

%%
fVals = data_info.stim_param.fVals; %% 
% find out the fVals for each epoch. %% If you finish this, could go home!
% Milk works! Just a lot of sugar...
f_vals = repmat(fVals', [1, 4, 2]);
[on_idx, off_idx, ~] = SAC_SineWave_Utils_AverageOverTime_CalOnOffIdx(1, f_vals);

%% calculate over time.
[resp_over_time] = SAC_AverageResponseOverTime(resp, on_idx(:), off_idx(:));
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp_over_time);
[resp_over_dir, data_info_over_dir, epoch_ID_over_dir] = SAC_AverageResponse_By(resp_over_time, data_info, 'dirVal','sub', epoch_ID);
[~, resp_ave_over_dir, resp_sem_over_dir] = SAC_GetAverageResponse(resp_over_dir);

%% plot colorplot. get the color map later on...
n_f = 10; n_k = 4; n_d = 2;
resp_reshape = reshape(resp_ave, n_f, n_k, n_d);
c_max = max(resp_ave);

%% two directions.
MakeFigure;
subplot(1,4,1);
SAC_SineWave_Plot_Utils_KFPlot(resp_reshape(:,:,1), 1, c_max);
title('preferred direction');

subplot(1,4,2);
SAC_SineWave_Plot_Utils_KFPlot(resp_reshape(:,:,2), 1, c_max);
title('null direction');

subplot(1,4,3);
SAC_SineWave_Plot_Utils_KFPlot(reshape(resp_ave_over_dir, n_f, n_k), 0, c_max);
title('preferred - null');

end
