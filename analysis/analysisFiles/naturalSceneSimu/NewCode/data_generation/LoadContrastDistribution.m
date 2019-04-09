function contrast_distribution_data_points = LoadContrastDistribution(filefolder)
    fileinfo = dir(fullfile(filefolder, '*.mat'));
    filepath = fullfile(filefolder, fileinfo.name);
    load(filepath);
end