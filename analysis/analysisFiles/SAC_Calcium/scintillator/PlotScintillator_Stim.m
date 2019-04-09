% Plot scintillator Stim.
clc
clear
load('D:\data_sac_calcium_new\C2_scintillator.mat');


%% 
n_time = 6;
n_dir = 2;
dtVals = [0:5];
dirVals = [1,-1];

n_par = 2;
parvals = [1, -1];

trial_index = zeros(n_time, n_dir, n_par);
for pp = 1:1:n_par
    for dd = 1:1:n_dir
        for tt = 1:1:n_time
            trial_index(tt,dd,pp)= find(p.dtVals == dtVals(tt) & p.displacementVals == dirVals(dd) ...
            & p.parityVals == parvals(pp));
        end
    end
end

%% take a look at the contrast, as well as the correlation? 
%% have a rest.
MakeFigure;
for pp = 1:1:n_par
    for dd = 1:1:n_dir
        for tt = 1:1:n_time
            subplot(4, n_time, ((pp-1) * 2 + dd - 1) * n_time + tt);
            cont = squeeze(p.cont(:,:,trial_index(tt, dd, pp)));
            [T, X] = size(cont);
            r = xcorr2(cont);
            r = r(T-5:T+5, X-2:X+2);
            imagesc(r); colormap(gray);
            set(gca, 'XTick',[2,3,4], 'XTickLabel',{'-1','0','1'}, 'YTick',[5,6,7], 'YTickLabel',{'-1','0','1'});
        end
    end
end

%% stimulus makes sense...
