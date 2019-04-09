function [stim_info, data_info] = SAC_SineWave_Utils_GetStimParam()
S = GetSystemConfiguration;
stim_dir = fullfile(S.sac_data_path, 'stim_info');
load(fullfile(stim_dir, 'C3_sinusoid_sweep.mat'));

n_k = 4;
n_f = 10;
n_d = 2; % two directions.


kVals = 1./[15, 30, 60, 90]; %% spatial frequency. unit 1/degree
fVals  = sqrt(2).^([0:9] - 2); %% temporal frequency. unit 1/second
dirVal = [1,-1];
p.divVal = [ones(1,40), -ones(1,40)];

epoch_index = zeros(n_f, n_k, n_d);
stim_xt = cell(n_f, n_k, n_d);
for ff = 1:1:n_f
    for kk = 1:1:n_k
        for dd = 1:1:n_d
            epoch_index(ff, kk, dd) = find(p.kVals == kVals(kk) & abs(p.fVals - fVals(ff))<1e-5 & p.divVal == dirVal(dd));
            stim_xt{ff, kk, dd} = (p.cont(:,:,epoch_index(ff, kk, dd)));
        end
    end
end

param.kVals = kVals;
param.fVals = fVals;
param.dirVal = dirVal;

param_vec.kVals = p.kVals;
param_vec.fVals = p.fVals;
param_vec.dirVal = p.dirVal;

data_info.epoch_index = epoch_index; %% organize them together
data_info.param_name = {'t_f','x_f','dirVal'};
data_info.stim_param = param;

%
stim_info.epoch_cont = p.cont; %% Original cont corresponding to param_vec
stim_info.cont = stim_xt; %% This is after organization.
stim_info.param_name = {'t_f','x_f','dirVal'};
stim_info.param = param;
stim_info.param_vec = param_vec;
end
