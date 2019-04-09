function I = Generate_VisualStim_And_VelEstimation_Utils_LoadImage(imageID,synthetic_image_source_full_path, synthetic_type)
if isempty(synthetic_type)   
    synthetic_type = ''; % is it is empty, it is actully natural scene.
end
    switch synthetic_type
        case 'm_sc_m_cd'
            image_this = [];
            image_mean_info = load(fullfile(synthetic_image_source_full_path, 'med_sc_cd.mat'));
            I = SyntheticScene_Utils_GenerateOneImage(image_this, image_mean_info, synthetic_type);
        case 'm_sc_m_var'
            % load power spectrum and generating a image here. 
            image_this = [];
            image_mean_info = load(fullfile(synthetic_image_source_full_path, 'power_spectrum.mat'));
            I = SyntheticScene_Utils_GenerateOneImage(image_this, image_mean_info, synthetic_type);
        case 'med_i_sc_iskew_solution'
            I = LoadCalculatedSolution(imageID,synthetic_image_source_full_path);
        otherwise
            I = LoadProcessedImage(imageID,synthetic_image_source_full_path);
    end
end