function I_syn = SyntheticScene_Utils_GenerateOneImage(image_this, image_mean_info,synthetic_type)
% a lot of switch.
switch synthetic_type
    case 'm_sc_m_var'
        I_syn = SyntheticScene_Utils_GenerateOneImage_m_sc_m_var(image_mean_info.power_spectrum_mean); 
    case 'm_sc_m_cd'
        I_syn = SyntheticScene_Utils_GenerateOneImage_m_sc_m_cd(image_mean_info.med); 
    case 'm_sc_i_var' % no need to generate beforehand. you can also do it anyways, not neccessay.
        I_syn = SyntheticScene_Utils_GenerateOneImage_m_sc_i_var(image_this.I, image_mean_info.	power_spectrum_mean);
        % test passed
    case 'm_var_i_sc'
        I_syn = SyntheticScene_Utils_GenerateOneImage_m_var_i_sc(image_this.I, image_mean_info.power_spectrum_mean);
        % test passed
    case 'i_sc_i_var'
        I_syn = SyntheticScene_Utils_GenerateOneImage_i_sc_i_var(image_this.I);
        % test passed
    case 'm_sc_i_cd'
        I_syn = SyntheticScene_Utils_GenerateOneImage_med(image_this.med);
        % test passed
    case 'i_sc_i_cd'
        I_syn = SyntheticScene_Utils_GenerateOneImage_med(image_this.med);
        
    otherwise
end
end

function  I_syn = SyntheticScene_Utils_GenerateOneImage_m_var_i_sc(I, mean_power_spectrum )
I_syn = zeros(size(I))    ;
n_ver = size(I, 1);
for ii = 1:1:n_ver
    I_syn(ii, :) = Generate_VisualStim_And_VelEstimation_Utils_SC(I(ii, :), 'individual_spatial_corr_mean_variance', 'mean_power_spectrum',mean_power_spectrum);
end
end

function  I_syn = SyntheticScene_Utils_GenerateOneImage_m_sc_i_var(I, mean_power_spectrum )
I_syn = zeros(size(I))    ;
n_ver = size(I, 1);
for ii = 1:1:n_ver
    I_syn(ii, :) = Generate_VisualStim_And_VelEstimation_Utils_SC(I(ii, :), 'mean_spatial_corr_individual_variance', 'mean_power_spectrum',mean_power_spectrum);
end
end

function I_syn = SyntheticScene_Utils_GenerateOneImage_i_sc_i_var(I)
I_syn = zeros(size(I))    ;
n_ver = size(I, 1);
for ii = 1:1:n_ver
    I_syn(ii, :) = Generate_VisualStim_And_VelEstimation_Utils_SC(I(ii, :),  'individual_spatial_corr_individual_variance');
end
end

function I_syn = SyntheticScene_Utils_GenerateOneImage_med(med_all)
n_ver =length(med_all);
n_hor = 927;
I_syn = zeros(n_ver, n_hor) ;
tic
parfor ii = 1:1:n_ver
    med = med_all(ii);
%     I_syn(ii, :) = MaxEntDist_AllMar_TwoCov_Utils_GibbsSampling_OneScene(med.x_solved_scale, med.gray_value_mean_subtracted_scale, med.gray_value, med.N, med.K, med.resolution_n_pixel);
    I_syn(ii, :) = MaxEntDist_AllMar_TwoCovFull_Utils_GibbsSampling_OneScene(med.x_solved_scale, med.gray_value_mean_subtracted_scale, med.gray_value, med.N, med.K, med.resolution_n_pixel);
end
toc
end

function  I_syn = SyntheticScene_Utils_GenerateOneImage_m_sc_m_cd(med) 
n_ver = 251;
n_hor = 927;
I_syn = zeros(n_ver, n_hor) ;
for ii = 1:1:n_ver
    I_syn(ii, :) = MaxEntDist_AllMar_TwoCov_Utils_GibbsSampling_OneScene(med.x_solved_scale, med.gray_value_mean_subtracted_scale, med.gray_value, med.N, med.K, med.resolution_n_pixel);
end
end

function I_syn = SyntheticScene_Utils_GenerateOneImage_m_sc_m_var(mean_power_spectrum)
n_ver = 251;
n_hor = length(mean_power_spectrum);
I_syn = zeros(n_ver, n_hor);
x_dummy = rand(n_hor, 1);
for ii = 1:1:n_ver
    I_syn(ii, :) = Generate_VisualStim_And_VelEstimation_Utils_SC(x_dummy, 'mean_spatial_corr_mean_variance', 'mean_power_spectrum',mean_power_spectrum);
end
end