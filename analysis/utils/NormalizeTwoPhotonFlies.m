function normalizedResponse = NormalizeTwoPhotonFlies(flyResp, normalizeEpoch, params)

selectivityEpoch = ConvertEpochNameToIndex(params,normalizeEpoch);

meanSelResps = cellfun(@(selectEpResps) mean(selectEpResps(:)), flyResp(selectivityEpoch, :), 'UniformOutput', false);

repeatedMeanSelResps = repmat(meanSelResps, [size(flyResp, 1), 1]);

% normalizedResponse = cellfun(@(epochResps, meanSelResp) epochResps/meanSelResp, flyResp, repeatedMeanSelResps, 'UniformOutput', false);
normalizedResponse = flyResp;
normalizedResponse(:, cat(2,meanSelResps{:})<1) = [];