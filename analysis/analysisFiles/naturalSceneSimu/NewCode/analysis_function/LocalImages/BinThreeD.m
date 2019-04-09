function [count_each_bin, sum_Y_each_bin] = BinThreeD(X, Y, edges)
bins_x = zeros(size(X));
n_bin = cellfun(@(x) length(x) - 1, edges);
n_x = zeros(9, size(X, 2));
for ii = 1:1:size(X, 2)
    [n_x(1:n_bin(ii), ii),~,bins_x(:, ii)] = histcounts(X(:, ii),edges{ii});
end


%% each category would have the corresponding index.
index_for_each_bin = zeros(prod(n_bin), 3);
[index_for_each_bin(:, 1), index_for_each_bin(:, 2), index_for_each_bin(:, 3)] = ind2sub(n_bin, 1: prod(n_bin));
count_each_bin = zeros(n_bin);
sum_Y_each_bin = zeros(n_bin);

for idx = 1:1:prod(n_bin)
    selected_scene = bins_x(:, 1) == index_for_each_bin(idx, 1) & ...
        bins_x(:, 2) == index_for_each_bin(idx, 2) & ...
        bins_x(:, 3) == index_for_each_bin(idx, 3);
    
    count_each_bin(idx) = sum(selected_scene(:));
    sum_Y_each_bin(idx) = sum(Y(selected_scene(:)));
end
end