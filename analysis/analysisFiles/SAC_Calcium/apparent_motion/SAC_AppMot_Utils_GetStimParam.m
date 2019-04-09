function [stim_info, data_info] = SAC_AppMot_Utils_GetStimParam()
S = GetSystemConfiguration;
stim_dir = fullfile(S.sac_data_path, 'stim_info');
load(fullfile(stim_dir, 'C1_apparent_motion.mat'));

n_lead_cont = 2;
n_lag_cont = 2;
n_dir = 2;
n_lag = 3;

leadCont = [1,-1];
lagCont  = [1,-1];
dirVal = [1,-1];
lagPos = [2,3,4];

epoch_index = zeros(n_lead_cont, n_lag_cont, n_dir, n_lag);
stim_xt = cell(n_lead_cont, n_lag_cont, n_dir, n_lag);
for cc_lead = 1:1:n_lead_cont
    for cc_lag = 1:1:n_lag_cont
        for dd = 1:1:n_dir
            for ll = 1:1:n_lag
                epoch_index(cc_lead, cc_lag, dd, ll) = find(p.lagCont == lagCont(cc_lag) & p.leadCont == leadCont(cc_lead) ...
                    & p.dirVal == dirVal(dd) & p.lagPos == lagPos(ll));
                stim_xt{cc_lead, cc_lag, dd, ll} = (p.cont(:,:,epoch_index(cc_lead, cc_lag, dd, ll)));
            end
        end
    end
end

param.leadCont = leadCont;
param.lagCont = lagCont;
param.dirVal = dirVal;
param.lagPos = lagPos;

param_vec.leadCont = p.leadCont;
param_vec.lagCont = p.lagCont;
param_vec.dirVal = p.dirVal;
param_vec.lagPos = p.lagPos;

data_info.epoch_index = epoch_index; %% organize them together
data_info.param_name = {'leadCont','lagCont','dirVal','lagPos'};
data_info.stim_param = param;

%
stim_info.epoch_cont = p.cont; %% Original cont corresponding to param_vec
stim_info.cont = stim_xt; %% This is after organization.
stim_info.param_name = {'leadCont','lagCont','dirVal','lagPos'};
stim_info.param = param;
stim_info.param_vec = param_vec;
end
