function [integrate_on_idx, integrate_off_idx, n_period_integral] = SAC_SineWave_Utils_AverageOverTime_CalOnOffIdx(set_integrate_len, f_vals)
stim_onset = 1;  % 1 sec
stim_offset = 6; % 6 sec
f_resp = 15.625; % response sampling frequency.
stim_dur_use = 4.5; % do not use the full 5 second. do not like the ramping up.

if ~set_integrate_len
    %% in terms of idx. not time.
    integrate_on_idx = ceil(stim_onset * f_resp);
    integrate_off_idx = floor(stim_offset * f_resp);
    n_period_integral = [];
else
    if isempty(f_vals)
        error('You need to provide f_vals');
    end
    integrate_off_idx = repmat(floor(stim_offset * f_resp), size(f_vals));
    [n_resp_sampling_integral, n_period_integral] = SAC_SineWave_Utils_AverageOverTime_IntegerCycle(f_vals, stim_dur_use);
    integrate_on_idx = floor(stim_offset * f_resp) - n_resp_sampling_integral;
end
end

function [n_resp_sampling_integral, n_period_integral] = SAC_SineWave_Utils_AverageOverTime_IntegerCycle(fVals, stim_dur)
f_resp = 15.625;
%% number of periods should you integrate.
period_vals = 1./fVals;
n_period = stim_dur./period_vals;
n_period_integral = floor(n_period); %% still, times the corresponding...
%% number of responses sampled should you integrate.
n_resp_sampling = (f_resp * n_period_integral .* period_vals);
n_resp_sampling_integral = round(n_resp_sampling);
end