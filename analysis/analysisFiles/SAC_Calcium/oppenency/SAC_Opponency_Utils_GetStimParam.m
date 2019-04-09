function [stim_info, data_info] = SAC_Opponency_Utils_GetStimParam()
S = GetSystemConfiguration;
stim_dir = fullfile(S.sac_data_path, 'stim_info');
load(fullfile(stim_dir,'C4_sinusoid_opponent.mat'));

n_phase = 8;
n_dir = 3; %% left, right, opponency.
dirVals = [1, -1, 0]; % preferred. null.
phaseVals = [1:8];
epoch_index = zeros(n_phase,n_dir);
for dd = 1:1:n_dir
    for pp = 1:1:n_phase 
        epoch_index(pp, dd) = (dd - 1) * 8 + pp;
    end
end

%% offset of phase.. how to tell?
param.phasevals = [1:8];
param.dirVals = dirVals;

param_vec.phasevals = phaseVals;
param_vec.dirVals = dirVals;

data_info.epoch_index = epoch_index; %% organize them together
data_info.param_name = {'phase','dir'};
data_info.stim_param = param;

%
stim_info.epoch_cont = p.cont; %% Original cont corresponding to param_vec
stim_info.param_name = {'phase','dir'};
stim_info.param = param;
stim_info.param_vec = param_vec;
end
