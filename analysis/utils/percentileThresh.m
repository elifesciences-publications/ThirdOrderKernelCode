function thresh = percentileThresh( set, percentThresh )
% Returns the value of the threshold giving the required percentile. If an
% array is given, does this on a per-column basis.

if ~isempty(percentThresh)
    if sum(size(set)>1)==1
        set(isnan(set)) = [];
        set = set(:);
        sortSet = sort(set);
        setCutoffInd = round(length(set)*percentThresh);
        if setCutoffInd == 0
            setCutoffInd = 1;
        end
        if isempty(set)
            % NOTE: I'm not sure setting this to 0 is the appropriate move.
            % 0 isn't technically the lowest fluorescence value that can
            % happen, as you could potentially have a negative. Maybe empty
            % should be what happens here? Let higher functions figure out
            % what to do?
            thresh=0;
        else
            thresh = sortSet(setCutoffInd);
        end
    else
        % Calculation per column if it's an array
        sortSet = sort(set);
        numGoodValsSet = size(set, 1) - sum(isnan(sortSet));
        setCutoffInd = round(numGoodValsSet*percentThresh);
        [~, indexMat] = meshgrid(1:size(set, 2), 1:size(set, 1));
        valDesired = bsxfun(@eq, setCutoffInd, indexMat);
        if isempty(set)
            % NOTE: I'm not sure setting this to 0 is the appropriate move.
            % 0 isn't technically the lowest fluorescence value that can
            % happen, as you could potentially have a negative. Maybe empty
            % should be what happens here? Let higher functions figure out
            % what to do?
            thresh=0;
        else
            thresh = sortSet(valDesired)';
        end
    end
else
    thresh = 0;
end

end