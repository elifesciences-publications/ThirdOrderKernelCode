function Figure5CD_SceneDemo()
%% The color scheme has been changed in the actual paper figure.
%% image 1 and row 20.
clear
clc
%% get data.
% datastr = {'sym_var', 'sym_skew'};
% dataset = {'syn_solu', 'syn_I'};
% datamode = {'natural scene'};

%% For demonstration purpose, the syn_I is enforced to have constrained skewness. For performance evaluation, it is not enforced.
syn_I = {'statiche0syn_pixel_dist_ivar_mean_selective',...
    'statiche0syn_pixel_dist_iskew_mean_selective'};
syn_solu = {'statiche0syn_pixel_dist_ivar_mean_solu',...
    'statiche0syn_pixel_dist_iskew_mean_solu'};

n_highest_moments = [2,3];
med = cell(2,1);
p_i = cell(2, 1);
I   = cell(3, 1);
[I{1},~,~]= load_image_and_p('natural_scene', '',  0);
for ii = 1:1:length(syn_I)
    [~, med{ii}, p_i{ii}] = load_image_and_p('syn_solu', syn_solu{ii},  n_highest_moments(ii));
    [I{ii + 1},~,~] = load_image_and_p('syn_I', syn_I{ii}, n_highest_moments(ii));
end

% for the sake of stacking two lines beautifully together, splot the second
% one.
I{3} = fliplr(I{3});
ExampleSceneMED_Demo_Plotting(med, p_i, I);
end
% MySaveFig_Juyue(gcf, 'new_demo_two_scene','image1_row209','nFigSave',2,'fileType',{'pdf','fig'});
