function timeTraceForRoi = LoadRawTraces( dataPath, roiMaskInitial)


% changeableVals = {'filterMovie', 0, 'takeSqrtICA', 0, 'calcDFOverFByRoi', 1, 'backgroundSubtractMovie', 1, 'useAlignedData', 1};
% [~, ~, argsVarlyIn] = AdjustEpochsForEye(dataPath, [], [], changeableVals{:}, argsVarlyIn{:});
% [lastRoi, ~] = LoadLastSavedRoiFile(dataPath, argsVarlyIn{:});
% roiMaskInitial = lastRoi.roiMaskInitial;

%% We need to cut the movie appropriately to make sure things are identical as in the normal process of running these flies...
%% load image description
imageDescription = LoadImageDescription(dataPath);
if isempty(imageDescription)
    warning('Wat! Returned...');
    return
else
    dataRate = imageDescription.acq.frameRate; % imaging frequency
end


%% Read in photodiode
% Discarding the flyback line means the lines per frame go from,
% say, 128 to 127, because that last line happens when the mirrors
% are repositioning to the top corner of the frame
[photoDiode, highResLinesPerFrame] = ReadInPhotodiode(imageDescription, dataPath);

%% get epoch list
[epochBegin, epochEnd, ~] = GetStimulusBounds(photoDiode, highResLinesPerFrame, dataRate);

alignmentData = [];
zoomLevel = [];
filterMovie = false;
backgroundSubtractMovie = false;
useAlignedData = true;

processedMovie = LoadAndProcessMovieData(dataPath, alignmentData, zoomLevel, filterMovie, backgroundSubtractMovie, useAlignedData);
processedMovie = processedMovie(:, :, round(epochBegin):round(epochEnd));
mvSz = size(processedMovie);
mvSz = mvSz(1:2);
mskSz = size(roiMaskInitial);
rowCol = (mvSz-mskSz)/2;
processedMovie = processedMovie(rowCol(1)+1:end-rowCol(1), rowCol(2)+1:end-rowCol(2), :);
processedMovieReshaped = reshape(processedMovie, [size(processedMovie, 1)*size(processedMovie, 2) size(processedMovie, 3)]);
roiMaskReshaped = reshape(roiMaskInitial, [size(roiMaskInitial, 1)*size(roiMaskInitial, 2) 1]);

roiNums = unique(roiMaskReshaped);
roiNums(roiNums==0) = [];

timeTraceForRoi = zeros(size(processedMovie, 3), length(roiNums));
for i = 1:length(roiNums)
%     timeTraceForRoi(:, i) = ((roiMaskReshaped == roiNums(i))'*processedMovieReshaped)'/sum(roiMaskReshaped==roiNums(i));
timeTraceForRoi(:, i) = mean(processedMovieReshaped(roiMaskReshaped == roiNums(i), :),1)';
end




end