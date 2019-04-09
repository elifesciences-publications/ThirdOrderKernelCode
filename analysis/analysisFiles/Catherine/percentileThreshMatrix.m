function thresh = percentileThreshMatrix(set, percentThresh)

    if ~isempty(percentThresh)
        set(isnan(set)) = [];
        set = set(:);
        sortSet = sort(set);
        setCutoffInd = round(length(set) * percentThresh);
        if setCutoffInd == 0;
            setCutoffInd = 1;
        end
        thresh = sortSet(setCutoffInd);
    else
        thresh = 0;
    end
end