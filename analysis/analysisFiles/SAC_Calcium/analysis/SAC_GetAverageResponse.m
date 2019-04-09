function [resp_ind_cell_mat, resp_ave_over_cell, resp_sem_over_cell] = SAC_GetAverageResponse(resp)% for any response... averaging Three level...
% over trials, over rois, over flies.
n_cell = length(resp);

resp_ind_cell = cell(n_cell, 1);
for nn = 1:1:n_cell
    resp_ave_over_trial =  mean(resp{nn}, 2);
    resp_ave_over_roi = mean(resp_ave_over_trial, 4);
    resp_ind_cell{nn} = squeeze(resp_ave_over_roi);
end
resp_ind_cell_mat = cat(3, resp_ind_cell{:});
resp_ave_over_cell = mean(resp_ind_cell_mat, 3);
resp_std_over_cell = std(resp_ind_cell_mat, 1, 3);
resp_sem_over_cell = resp_std_over_cell./sqrt(n_cell);
end

% function SAC_GetAverageResponse_AcrossRois(resp);
% %input cell-- different cells. but concatenate different rois. treat each
% %individual rois as independent measure
% end
% 
% function SAC_GetAverageResponse_AcrossTrials(resp);
% %input cell-- different cells. but concatenate different trials. treat each
% %individual trials as independent measure
% 
% % sometimes, you have to do normalization/subtraction on roi basis..
% % sometimes, you have to do normalization/subtraction on trial basis..
% % sometimes, you have to do mormalization/subtraction on cell basis.. 
% % not easy...
% end