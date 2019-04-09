%%
clc
clear
load('D:\data_sac_calcium_new\C2_scintillator.mat');

%% oranize trials by the leadCont and lagCont.
n_cont_type = 4;
% not sure
fVals =  [0.5000    0.7071    1.0000    1.4142    2.0000    2.8284    4.0000    5.6569    8.0000   11.3137]; % in Hz? or in what?
kVals  = 1./[15, 30, 60, 90];
dirVal = [];
% inside each, have the
n_spat_type = 6;
dirVal = [1,-1,1,-1,1,-1];
lagPos = [2,2,3,3,4,4];

trial_index = zeros(n_cont_type, n_spat_type);
for cc = 1:1:n_cont_type
    for ss = 1:1:n_spat_type
        trial_index(cc,ss) = find(p.lagCont == lagCont(cc) & p.leadCont == leadCont(cc) ...
            & p.dirVal == dirVal(ss) & p.lagPos == lagPos(ss));
    end
end

