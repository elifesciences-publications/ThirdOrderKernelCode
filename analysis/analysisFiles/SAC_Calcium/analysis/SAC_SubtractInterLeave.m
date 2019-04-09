function [ resp_ind_cell] = SAC_SubtractInterLeave(resp)% for any response... averaging Three level...
n_frames = 5;
stim_onset_frames = 15;

% do not over think...
n_cell = length(resp);
resp_ind_cell = cell(n_cell, 1);
for nn = 1:1:n_cell
    % 5 frames( 300 ms before )
    resp_ind_cell{nn} = resp{nn} - resp{nn}(stim_onset_frames - n_frames:stim_onset_frames, :,:,:);
end

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