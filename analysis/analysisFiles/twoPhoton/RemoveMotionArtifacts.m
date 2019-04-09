function flyResp = RemoveMotionArtifacts(flyResp, alignmentData, zoomLevel, movieSize, linescan, percNanThresh)
% First attempt to get rid of data points where there is too much motion

% if nargin > 4
%     linescan = true;
% else
%     linescan = false;
% end
% ySize = imgSize(2);
% xSize = imgSize(1);
% dSize = sqrt(ySize^2 + xSize^2);

if linescan
    fullShift = alignmentData;
    micronMovementMax = 15;
else
    fullShift = sqrt(alignmentData(:, 1).^2 + alignmentData(:, 2).^2);
    micronMovementMax = 5;
end

sysConfig = GetSystemConfiguration;
xAxisConversion = 256/movieSize(2); % This comes as a result of our calibration being for 256 pixels on the x-axis
pixelMotionMax = micronMovementMax * sysConfig.twoPhotonOneXPixelPerMicron256PixelXAxisRes * zoomLevel * xAxisConversion;


% diffShift = [0 0; diff(alignmentData(:, 1:2))];
% diffFullShift = sqrt(diffShift(:, 1).^2 + diffShift(:, 2).^2);

% We're tracking the diffShift here for if the image ends up at a resting
% state...
overMovedFrames = fullShift > pixelMotionMax;%(alignmentData(:, 1)>xSize*.1 | alignmentData(:, 1)>ySize*.1 | fullShift > dSize*.1);% & (diffShift(:, 1)>xSize*.1 | diffShift(:, 1)>ySize*.1 | diffFullShift > dSize*.1);
% meanCorrelation = mean(alignmentData(:, 3));
% stdCorrelation = std(alignmentData(:, 3));
% badlyCorrelatedFrames = alignmentData(:, 3)<(meanCorrelation-2*stdCorrelation);
% response is zeros...
percNan = 100*sum(overMovedFrames)/size(flyResp, 1);
if percNan > percNanThresh
    flyResp = [];
else
    flyResp(overMovedFrames, :) = NaN;
end