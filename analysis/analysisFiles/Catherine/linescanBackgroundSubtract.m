function [timeByRois, exponential, A] = linescanBackgroundSubtract(filteredMovie, roiMaskInitial,epochStartTimes,epochDurations,interleaveEpoch, linescan)

filteredMovieReshaped = reshape(filteredMovie, [size(filteredMovie, 1)*size(filteredMovie, 2) size(filteredMovie, 3)]);
roiMaskReshaped = reshape(roiMaskInitial, [size(roiMaskInitial, 1)*size(roiMaskInitial, 2) 1]);
uniqueRois = unique(roiMaskReshaped);
uniqueRois(uniqueRois==0) = [];
timeTraces = zeros(size(filteredMovieReshaped, 2), length(uniqueRois));
for roiNum = 1:length(uniqueRois)
    timeTraces(:, roiNum) = ((roiMaskReshaped == roiNum)'*filteredMovieReshaped)'/sum(roiMaskReshaped==roiNum);
end
if isempty(timeTraces)
    timeByRois = [];
    exponential = [];
    A = [];
else
    timeTraces = permute(timeTraces, [2 3 1]);
    takeSqrt = false;
    [deltaFOverF, exponential, A] = CalcDeltaFOverF(timeTraces,epochStartTimes,epochDurations,interleaveEpoch, takeSqrt, 0, linescan);
    timeByRois = squeeze(deltaFOverF)';
end