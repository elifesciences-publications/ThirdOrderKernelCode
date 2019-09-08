function distribution = LoadSynthticDistribution(filefolder, synthetic_type)
    fileinfo = dir(fullfile(filefolder, [synthetic_type, '*.mat']));
    filepath = fullfile(filefolder, fileinfo.name);
    load(filepath);
    
    switch synthetic_type
        case 'constrast_dist'
            distribution = contrast_distribution_data_points;
        case 'spatial_corr'
            distribution = fft_mag;
        case 'med_sc_cd'
            distribution = med;
    end
end