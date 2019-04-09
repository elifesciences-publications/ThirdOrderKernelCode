function [flyResp, roiMask, extraVals] = RoiIsBckg(backgroundSubtractedMovie,deltaFOverF,epochStartTimes,epochDurations,params,varargin)
dimThreshLevel = .05;

%% First, pick background ROI so that we can exclude this area later
meanMovie = mean(backgroundSubtractedMovie,3);
fractionCutOff = 10;
threshold = prctile(reshape(meanMovie,[numel(meanMovie) 1]),fractionCutOff);
regionMap = meanMovie < threshold;

%% search for constrained area.
numPixelMin = 30;
bckgPixelPerLine = sum(regionMap,2);
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
lineMap = false(size(regionMap));
lineMap(whichLine:whichLine + numLines -1,:) = true;
smallBkgdMask = regionMap & lineMap;

roiMask = smallBkgdMask;

%% get roi response
[outputRows, outputCols, numTimepoints] = size(backgroundSubtractedMovie);
MovieFlattened = reshape(backgroundSubtractedMovie,outputRows*outputCols,numTimepoints);
flyResp = mean(MovieFlattened(smallBkgdMask(:),:),1)';

%%
if ~exist('extraVals', 'var')
    extraVals = [];
end
end
