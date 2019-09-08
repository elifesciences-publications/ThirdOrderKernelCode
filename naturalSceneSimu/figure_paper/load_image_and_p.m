function [I, med_data, p_i] = load_image_and_p(which_mode, which_set, n_highest_moments)
% image_id = 1;
row_id = 20;
%%
S = GetSystemConfiguration;
if strcmp(which_mode, 'natural_scene')
    
    image_data = load(fullfile(S.natural_scene_simulation_path,'image\statiche0\FWHM25\Image1.mat'));
    I = image_data.I(row_id, :);
    med_data = [];
    p_i = [];
    
elseif strcmp(which_mode, 'syn_solu')
    solu_path = fullfile(S.natural_scene_simulation_path, '\image',which_set,'FWHM25\Image1.mat');
    data = load(solu_path);
    med_data= data.med(row_id);
    [~, ~, p_i] = MaxEntDis_ConsMoments_Utils_PlotResult( med_data.x_solved,  med_data.gray_value,  med_data.mu_true, [],  n_highest_moments,  med_data.N,  med_data.K,'plot_flag',false);
    I = [];
else
    image_path = fullfile(S.natural_scene_simulation_path, '\image', which_set,'FWHM25\Image1.mat');
    data = load(image_path);
    I = data.I(row_id, :);
    med_data = [];
    p_i = [];
end

end