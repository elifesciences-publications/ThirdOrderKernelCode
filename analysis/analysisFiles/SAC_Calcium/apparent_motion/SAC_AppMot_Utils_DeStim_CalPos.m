function pos_three = SAC_AppMot_Utils_DeStim_CalPos(dir, lagPos)

stim_onset_lag = 15;
lag_pos_L = [stim_onset_lag + 0.5, lagPos - 0.5, 44.5, 1]; %% time. space.
if dir == 1
    lead_pos_E = [1, lagPos - 1 - 0.5, stim_onset_lag - 1, 1]; %% time. space.
    lead_pos_L = [stim_onset_lag + 0.5, lagPos - 1 - 0.5, 44.5, 1];
    lag_pos_L(2) = lag_pos_L(2) + 0.1;
    lag_pos_L(4) = lag_pos_L(4) - 0.1;
elseif dir == -1
    lead_pos_E = [1, lagPos + 1 - 0.5, stim_onset_lag - 1, 1]; %% time. space.
    lead_pos_L = [stim_onset_lag + 0.5, lagPos + 1 - 0.5, 44.5, 1];
    lag_pos_L(4) = lag_pos_L(4) - 0.1;
end

pos_three = [lead_pos_E; lead_pos_L;lag_pos_L];
end