function data = compute_image_skewness_pixel_or_distribution_change_N(N)
image_data_path = 'D:\Natural_Scene_Simu\image\statiche0\FWHM25';
image_info = dir(fullfile(image_data_path, '*.mat'));
n_image = length(image_info);
n_ver = 251;
data = cell(2, 1); % one for pixel form. % another for distribution form.
for ii = 1:1:2
    data{ii} = zeros(2, n_ver, n_image);
end
%%
tic
for ii = 1:1:n_image
    I = load(fullfile(image_data_path, image_info(ii).name));
    for jj = 1:1:size(I.I, 1)
        x = I.I(jj, :);
        [data{1}(:, jj,ii), data{2}(:, jj, ii)] = compute_image_skewness_pixel_or_distribution(x, N);
    end
end
toc
end