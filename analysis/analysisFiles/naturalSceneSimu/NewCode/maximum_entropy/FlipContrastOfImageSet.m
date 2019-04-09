function FlipContrastOfImageSet(source_folder_name, storage_folder_name)
S = GetSystemConfiguration;
source_folder_full_path = fullfile(S.natural_scene_simulation_path, 'image',source_folder_name, 'FWHM25');
storage_folder_full_path = fullfile(S.natural_scene_simulation_path, 'image',storage_folder_name, 'FWHM25');
if ~exist(storage_folder_full_path,'dir')
    mkdir(storage_folder_full_path)
end
image_data_info = dir(fullfile(source_folder_full_path, '*.mat'));
n_image = length(image_data_info);
for ii = 1:1:n_image
    I_source = load(fullfile(source_folder_full_path, image_data_info(ii).name));
    I = -I_source.I;
    save(fullfile(storage_folder_full_path, image_data_info(ii).name), 'I');
end
end