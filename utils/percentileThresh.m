function thresh = percentileThresh( set, percentThresh )
% Returns the value of the threshold giving the required percentile.

    if ~isempty(percentThresh)
        set = set(:);
        sortSet = sort(set);
        setCutoffInd = round(length(set)*percentThresh);
        thresh = sortSet(setCutoffInd);
    else
        thresh = 0;
    end     

end