function [stim_info, data_info] = SAC_Scintillator_Utils_GetStimParam()
S = GetSystemConfiguration;
stim_dir = fullfile(S.sac_data_path, 'stim_info');
load(fullfile(stim_dir,'C2_scintillator.mat'));

n_time = 6;
n_dir = 2;
n_par = 2;

dtVals = [0:5];
dirVals = [1,-1];
parvals = [1, -1];

epoch_index = zeros(n_time, n_dir, n_par);
stim_crosscorr = zeros(11, 5, n_time*n_dir*n_par );
for pp = 1:1:n_par
    for dd = 1:1:n_dir
        for tt = 1:1:n_time
            epoch_index(tt, dd, pp) = find(p.dtVals == dtVals(tt) & p.displacementVals == dirVals(dd) & p.parityVals == parvals(pp));
            cont = squeeze(p.cont(:,:,epoch_index(tt, dd, pp)));
            
            cont = cont - round(mean(cont(:))* 2) * 1/2;
            [T, X] = size(cont);
            r = xcorr2(cont);
            r_s = xcorr2(ones(size(cont)));
            r_coef = r./r_s;
            r_coef = r_coef/r_coef(T, X);

            r_coef = r_coef(T-5:T+5, X-2:X+2);
            stim_crosscorr(:,:,epoch_index(tt, dd, pp)) = r_coef;
        end
    end
end

param.parvals = parvals;
param.dtVals = dtVals;
param.dirVals = dirVals;

param_vec.dtVals = p.dtVals;
param_vec.displacementVals = p.displacementVals;
param_vec.parityVals = p.parityVals;

data_info.epoch_index = epoch_index; %% organize them together
data_info.param_name = {'dt','dir','pol'};
data_info.stim_param = param;

%
stim_info.epoch_cont = p.cont; %% Original cont corresponding to param_vec
stim_info.epoch_crosscorr = stim_crosscorr;
stim_info.param_name = {'dt','dir','pol'};
stim_info.param = param;
stim_info.param_vec = param_vec;
end

% MakeFigure; 
% subplot(2,2,1);
% histogram(p.cont(:,:,epoch_index(1, 1, 1)), [-0.1, 0.1,0.4, 0.6,0.9, 1.1], 'FaceColor',[0,0,0]);
% set(gca, 'XTick', [0,0.5, 1]);
% title('epoch 1 (positive correlation)');
% xlabel('contrast');
% ylabel('count');
% ConfAxis('fontSize', 13);
% subplot(2,2,2);
% histogram(p.cont(:,:,epoch_index(1, 1, 2)), [-0.6, -0.4, -0.1, 0.1,0.4, 0.6], 'FaceColor',[0,0,0]);
% set(gca, 'XTick', [-0.5, 0,0.5]);
% xlabel('contrast');
% ylabel('count');
% title('epoch 13 (negative correlation)');
% ConfAxis('fontSize', 13);

