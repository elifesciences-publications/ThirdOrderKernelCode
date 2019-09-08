function [image_set, count_each_bin] = NS_LocalScene_PreselectImage_By_LocalSatistics(X, edges, image_size, n_image)
num_set = 10;
bins_x = zeros(size(X));
n_bin = cellfun(@(x) length(x) - 1, edges);
%% choose four for each bin... ask numbers in each bin first.
%% you also want to just get highest skewness and kurtosis.
n_x = zeros(9, size(X, 2));
for ii = 1:1:size(X, 2)
    [n_x(1:n_bin(ii), ii),~,bins_x(:, ii)] = histcounts(X(:, ii),edges{ii});
end


%% each category would have the corresponding index.
index_for_each_bin = zeros(prod(n_bin), 3);
[index_for_each_bin(:, 1), index_for_each_bin(:, 2), index_for_each_bin(:, 3)] = ind2sub(n_bin, 1: prod(n_bin));
count_each_bin = zeros(n_bin);
image_ID_use = cell(n_bin);
image_row_use = cell(n_bin);
for idx = 1:1:prod(n_bin)
    selected_scene = bins_x(:, 1) == index_for_each_bin(idx, 1) & ...
        bins_x(:, 2) == index_for_each_bin(idx, 2) & ...
        bins_x(:, 3) == index_for_each_bin(idx, 3);
    selected_scene_mat = reshape(selected_scene, [image_size(1), n_image]);
    selected_scene_mat_non_contiguous = false(size(selected_scene_mat));
    for ii = 1:1:n_image
        
        CC = bwconncomp(selected_scene_mat(:, ii));
        for jj = 1:1:CC.NumObjects
            pixel_this_component = CC.PixelIdxList{jj}(1);
            selected_scene_mat_non_contiguous(pixel_this_component, ii) = 1;
        end
    end
    count_each_bin(idx) = sum(selected_scene_mat_non_contiguous(:));
    [image_row_use{idx}, image_ID_use{idx}] = ind2sub([image_size(1), n_image],find(selected_scene_mat_non_contiguous(:)));
end
count_each_bin_norm = count_each_bin/(n_image * image_size(1));

%% each bin has one point first,
%% then second point.
%% then third point... ect... 6 hour 1 data... okay...

image_set = repmat(struct('image_ID',[], 'image_row', []), num_set, 1);
for ii = 1:1:num_set
    n_data_in_one_set = sum(count_each_bin(:) >= ii);
    image_ID_this_set = zeros(n_data_in_one_set, 1);
    image_row_this_set = zeros(n_data_in_one_set, 1);
    counter = 1;
    for idx = 1:1:prod(n_bin)
        n_max = length(image_row_use{idx});
        if n_max >= ii
            image_ID_this_set(counter) = image_ID_use{idx}(ii);
            image_row_this_set(counter) = image_row_use{idx}(ii);
            counter = counter + 1;
        end
    end
    image_set(ii).image_ID = image_ID_this_set;
    image_set(ii).image_row = image_row_this_set;
end


end