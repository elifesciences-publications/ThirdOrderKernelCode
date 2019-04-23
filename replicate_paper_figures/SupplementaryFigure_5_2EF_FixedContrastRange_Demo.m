function SupplementaryFigure_5_2EF_FixedContrastRange_Demo()
%% get data.
syn_I = {'statiche0syn_pixel_dist_ivar_sym_0mean_fixedlh25_512bin',...
    'statiche0syn_pixel_dist_iskew_sym_0mean_fixedlh25_512bin'};
syn_solu = {'statichesyn0_pixel_dist_ivar_sym_0mean_fixedlh25_512bin_solu',...
    'statichesyn0_pixel_dist_iskew_sym_0mean_fixedlh25_512bin_solu'};

n_highest_moments = [2,3];
med = cell(2,1);
p_i = cell(2, 1);
I   = cell(3, 1);
[I{1},~,~]= load_image_and_p('natural_scene', '',  0);
for ii = 1:1:length(syn_I)
    [~, med{ii}, p_i{ii}] = load_image_and_p('syn_solu', syn_solu{ii},  n_highest_moments(ii));
    [I{ii + 1},~,~] = load_image_and_p('syn_I', syn_I{ii}, n_highest_moments(ii));
end

ExampleSceneMED_Demo_Plotting(med, p_i, I, 'plot_natural_scene_flag', 0);
set(gca, 'YLim', [0,0.0075]); % histogram
% set(gca, 'YLim', [-2.5,2.5]); % scene example.
end