function [trial_index, stim_data] = SAC_Scintillator_Utils_OrgStim()
S = GetSystemConfiguration;
stim_dir = fullfile(S.sac_data_path, 'stim_info');

load(fullfile(stim_dir, 'C2_scintillator.mat'));
%% 
n_time = 6;
n_dir = 2;

n_par = 2;
parvals = [1, -1];
dtVals = [0:5];
dirVals = [1,-1];

trial_index = zeros(n_time, n_dir, n_par);
stim_data = cell(n_time, n_dir, n_par);

for pp = 1:1:n_par
    for dd = 1:1:n_dir
        for tt = 1:1:n_time
            trial_index(tt,dd,pp)= find(p.dtVals == dtVals(tt) & p.displacementVals == dirVals(dd) ...
            & p.parityVals == parvals(pp));
            cont = squeeze(p.cont(:,:,trial_index(tt, dd, pp)));
            
            [T, X] = size(cont);
            r = xcorr2(cont);
            r = r(T-5:T+5, X-2:X+2);
            stim_data{tt, dd, pp} = r;
        end
    end
end

%% plot the stimulus, and response...



