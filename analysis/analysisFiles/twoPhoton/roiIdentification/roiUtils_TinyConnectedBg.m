function smallBkgdMask = roiUtils_TinyConnectedBg( Z )
% Automatically selects a dim connected region to use as a background.
% limit the size to be small. less than 10 pixels, so that you would
% extract background kernel from that.

dimThreshLevel = .05;
loadFlexibleInputs(Z);
% Grab movie
inMovie = Z.grab.imgFrames;
% Delete imgFrames; save movie average
Z.rawTraces.movieMean = mean(Z.grab.imgFrames,3);
Z.grab = rmfield(Z.grab,'imgFrames');


%% First, pick background ROI so that we can exclude this area later
if ~isfield(Z, 'rawTraces')
    meanMovie = mean(Z.grab.imgFrames,3);
else
    meanMovie = Z.rawTraces.movieMean;
end
% only use the meanMovie inside of the windMask.
windMask = Z.grab.windowMask;

imageSize = size(windMask);
windStart = find(windMask ,1,'first');
windEnd = find(windMask,1, 'last');
[verStart,horStart] = ind2sub(imageSize,windStart);
[verEnd,horEnd] = ind2sub(imageSize,windEnd);

meanMovieInWindow = meanMovie(verStart:verEnd,horStart:horEnd);
fractionCutOff = 10;
threshold = prctile(reshape(meanMovieInWindow,[numel(meanMovieInWindow) 1]),fractionCutOff);
regionMap = meanMovieInWindow < threshold;
regionMap_ = ICA_DFOVERF_Untils_RoiMaskCordChange(windMask,regionMap,imageSize);
% find the contiguous region.

% search for constrained area.
numPixelMin = 30;
bckgPixelPerLine = sum(regionMap_,2);
foundFlag = false;
numLines = 1;
numLinesMax = 2;
numPixelPerRegion = bckgPixelPerLine;
% this is a while loop which cannot get out...
while ~foundFlag || numLines >= numLinesMax
    [numThisLine,whichLine] = max(numPixelPerRegion);
    if numThisLine >= numPixelMin
        foundFlag = true;
    else
        numLines = numLines + 1;
        numPixelPerRegion = roiUtils_TinyConnectedBg_AddPixelPerLine(bckgPixelPerLine,numLines);
    end  
end
% if it is larger than 2 lines, just get the largest.
lineMap = false(size(regionMap_));
lineMap(whichLine:whichLine + numLines -1,:) = true;
smallBkgdMask = regionMap_ & lineMap;

end