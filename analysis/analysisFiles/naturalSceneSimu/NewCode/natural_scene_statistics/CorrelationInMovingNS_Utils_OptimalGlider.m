function B = CorrelationInMovingNS_Utils_OptimalGlider(stim_corr_data, v_real)
%% this optimal glider should be better.
stim_corr_data_ds = (stim_corr_data(:,:,1) - stim_corr_data(:,:,2))/2;
B = stim_corr_data_ds\v_real;

% calculate the partial variance.

% calculate the total explained variance. mse

end