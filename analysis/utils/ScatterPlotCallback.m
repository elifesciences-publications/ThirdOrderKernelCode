function ScatterPlotCallback(src, evt, flyResp, numRois, filteringCriteria, dataPath, argsVarlyIn)

if isempty(src.UserData)
    src.UserData(1) = figure;
end
if length(src.UserData)>1;
    delete(src.UserData(2));
end
xVals = src.XData;
yVals = src.YData;
ptClicked = evt.IntersectionPoint;
[~, loc] = min(sqrt((ptClicked(1)-xVals).^2 + (ptClicked(2)-yVals).^2));
figure(src.Parent.Parent);
r = plot(xVals(loc), yVals(loc), 'ro', 'LineWidth', 10);
src.UserData(2) = r;
actualRoi = find(filteringCriteria, loc, 'first');
actualRoi = actualRoi(end);
roiTally = cumsum(numRois);
flyNumForRoi = find(roiTally>actualRoi, 1);
if flyNumForRoi == 1
    roiInFly = actualRoi;
else
    roiInFly = actualRoi - roiTally(flyNumForRoi-1);
end
roiResp = flyResp{flyNumForRoi}(:, roiInFly);
figure(src.UserData(1))
subplot(2, 1, 1);
plot(roiResp);
hold on
m = axis;
plot(m(1:2), yVals([loc, loc]), '--k')
plot(m(1:2), xVals([loc, loc]), '--r')
hold off

changeableVals = {'filterMovie', 0, 'takeSqrtICA', 0, 'calcDFOverFByRoi', 1, 'backgroundSubtractMovie', 1, 'useAlignedData', 1};
[~, ~, argsVarlyIn] = AdjustEpochsForEye(dataPath{flyNumForRoi}, [], [], changeableVals{:}, argsVarlyIn{:});
[lastRoi, ~] = LoadLastSavedRoiFile(dataPath{flyNumForRoi}, argsVarlyIn{:});
roiMaskInitial = lastRoi.roiMaskInitial;

%% We need to cut the movie appropriately to make sure things are identical as in the normal process of running these flies...
%% load image description
imageDescription = LoadImageDescription(dataPath{flyNumForRoi});
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
[photoDiode, highResLinesPerFrame] = ReadInPhotodiode(imageDescription, dataPath{flyNumForRoi});

%% get epoch list
[epochBegin, epochEnd, ~] = GetStimulusBounds(photoDiode, highResLinesPerFrame, dataRate);


processedMovie = LoadAndProcessMovieData(dataPath{flyNumForRoi}, [], [], 0, 0, 1);
processedMovie = processedMovie(:, :, round(epochBegin):round(epochEnd));
mvSz = size(processedMovie);
mvSz = mvSz(1:2);
mskSz = size(roiMaskInitial);
rowCol = (mvSz-mskSz)/2;
processedMovie = processedMovie(rowCol(1)+1:end-rowCol(1), rowCol(2)+1:end-rowCol(2), :);
processedMovieReshaped = reshape(processedMovie, [size(processedMovie, 1)*size(processedMovie, 2) size(processedMovie, 3)]);
roiMaskReshaped = reshape(roiMaskInitial, [size(roiMaskInitial, 1)*size(roiMaskInitial, 2) 1]);

bgSubbedMovie = BackgroundSubtract(processedMovie);
bgSubbedMovieReshaped = reshape(bgSubbedMovie, [size(bgSubbedMovie, 1)*size(bgSubbedMovie, 2) size(bgSubbedMovie, 3)]);

interleaveEpoch = 13; % We're just gonna hardcode this here....
[~, exponential, A] = CalculatedDeltaFOverFByROI(bgSubbedMovie, roiMaskInitial,lastRoi.epochStartTimes,lastRoi.epochDurations,interleaveEpoch);

timeTraceForRoi = ((roiMaskReshaped == roiInFly)'*processedMovieReshaped)'/sum(roiMaskReshaped==roiInFly);
timeTraceForRoiBgSub = ((roiMaskReshaped == roiInFly)'*bgSubbedMovieReshaped)'/sum(roiMaskReshaped==roiInFly);
figure(src.UserData(1))
subplot(2, 1, 2);
plot(timeTraceForRoi, 'r');
hold on
plot(timeTraceForRoiBgSub, 'b');
plot([0, length(timeTraceForRoi)], A([roiInFly roiInFly]), 'k--');
plot(squeeze(exponential(roiInFly, :, :))', 'g');
legend({'No BG sub', 'BG sub'});
hold off
fprintf('This is ROI %d in fly %d for overall ROI %d\n', roiInFly, flyNumForRoi, loc);


end