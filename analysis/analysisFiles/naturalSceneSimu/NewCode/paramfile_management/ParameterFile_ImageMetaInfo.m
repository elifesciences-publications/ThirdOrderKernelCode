function image = ParameterFile_ImageMetaInfo()
S = GetSystemConfiguration;
meta_data_file = fullfile(S.natural_scene_simulation_path, 'parameterdata', 'Metadata.mat');
load(meta_data_file);
image.origin.hor.nPixel = length(Metadata.horsteps);
image.origin.ver.nPixel = length(Metadata.vertsteps);
image.origin.hor.degree = Metadata.horsteps;
image.origin.ver.degree = Metadata.vertsteps;
clear Metadata;

image.param.hor.nPixel = image.origin.hor.nPixel;
image.param.ver.nPixel = image.origin.ver.nPixel; % to be changed... 4 * sig. to be changed again.
image.param.hor.degree = image.origin.hor.degree;
image.param.ver.degree = image.origin.ver.degree; % to be changed.
image.param.hor.x = image.param.hor.degree;
image.param.hor.dx = image.param.hor.degree(2) - image.param.hor.degree(1);
end