function idx = utils_resample_data(x, n_sample)
% it is hard to do it naturally,
rng(0)
[~, ~, idx_bin] = histcounts(x, n_sample);
idx = zeros(n_sample, 1);
for ii = 1:1:n_sample
    if ~isempty(find(idx_bin == ii))
        idx(ii) = datasample(find(idx_bin == ii), 1);
    end
end
idx = idx(idx ~= 0);
end