clc
clear
load('D:\data_sac_calcium_new\C1_apparent_motion.mat');

%% oranize trials by the leadCont and lagCont.
n_cont_type = 4;
leadCont = [1, 1,-1, -1];
lagCont  = [1,-1, 1, -1];
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

%% another organization.
MakeFigure;
for cc = 1:1:n_cont_type
    for ss = 1:1:n_spat_type
        subplot(n_cont_type, n_spat_type, (cc - 1)*n_spat_type + ss)
        imagesc(p.cont(:,:,trial_index(cc,ss))); colormap(gray);
        set(gca, 'XTick',[], 'YTick', [], 'clim',[-1,1]);
    end
end
