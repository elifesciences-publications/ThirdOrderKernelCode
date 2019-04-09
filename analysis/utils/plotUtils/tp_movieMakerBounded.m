function tp_movieMakerBounded(Z, movieBounds, inTime)
%Function asks the user for a tif input file (one taken from a loop grab of
%scanimage) and outputs an AVI file that puts together all the images
%grabbed in the loop like a movie.

%Varargin defaults!
movieFps = []; %becomes capture frame rate if nothing else is assigned to it
fnEnd = '';
if nargin<2 || isempty(movieBounds)
    movieBounds = [1, size(Z.filtered.roi_avg_intensity_filtered_normalized, 1)];
elseif nargin==3 && inTime
    movieBounds = ceil(movieBounds.*Z.params.fps+0.001);
end

masks = Z.ROI.roiMasks;
if isfield(Z.ROI, 'roiIndsOfInterest')
    indsToPlot = Z.ROI.roiIndsOfInterest;%subtract one to get rid of average ind
    if ~any(indsToPlot)
        warning('No roiIndsOfInterest were extracted! Plotting all masks');
    else
        masks = masks(:, :, indsToPlot);
    end
end
    
% Receive input variables
loadFlexibleInputs(Z);

[imgFramesInit, ~, tifInfDescription, ~] = twoPhotonImageParser(Z);
% imgFramesInit = imgFramesInit/(mean(imgFramesInit(:))+3*std(imgFramesInit(:)));
imgFramesInit(imgFramesInit==0) = min(imgFramesInit(imgFramesInit~=0));
imgFramesInit = log(imgFramesInit(:, :, movieBounds(1):movieBounds(2)));
mxImage = max(imgFramesInit(:));
imgFramesInit = imgFramesInit/mxImage;


fnEnd = ['bounds' num2str(movieBounds(1)) '-' num2str(movieBounds(2))];




if isempty(movieFps)
    %Grab frame rate that capture occurred at
    fpsCell = regexp(tifInfDescription, 'frameRate=(\d+.*\d+)', 'tokens');
    fpsSmallCell = [fpsCell{~cellfun('isempty', fpsCell)}];
    movieFps = str2double(fpsSmallCell{:});
end
if ~isempty(fnEnd)
    %DAT UNDAHSCO'!
    fnEnd = ['_' fnEnd];
end

outFilename = fullfile(Z.params.pathName, [Z.params.name, fnEnd, '.avi']); %default output filename

masksCell = mat2cell(masks, size(masks, 1), size(masks, 2), ones(size(masks, 3), 1));
boundedMasksCell = cellfun(@(layer) bwperim(layer), masksCell, 'UniformOutput', false);
boundariesMatrix = cell2mat(boundedMasksCell);
boundariesMatrix = any(boundariesMatrix, 3);




%Gotta reconvert imgFrames to a 4D with each 4th dimension being a 3D
%frame
windowMask = logical(Z.grab.windowMask);
[r, c] = find(windowMask);
imgFrames = zeros(r(end)-r(1)+1, c(end)-c(1)+1, 3, size(imgFramesInit, 3));
for ind = 1:size(imgFramesInit, 3);
    if ~mod(ind, 100)
        disp(['Making frame ' num2str(ind)])
    end
    imgFramesHere = imgFramesInit(:, :, ind);
    frameLayerR = reshape(imgFramesHere(windowMask), [r(end)-r(1)+1, c(end)-c(1)+1]);
%     frameLayerR(boundariesMatrix) = 1;
    frameLayerG = reshape(imgFramesHere(windowMask), [r(end)-r(1)+1, c(end)-c(1)+1]);
%     frameLayerG(boundariesMatrix) = 0;
    frameLayerB = reshape(imgFramesHere(windowMask), [r(end)-r(1)+1, c(end)-c(1)+1]);
%     frameLayerB(boundariesMatrix) = 0;
    imgFrames(:, :, :, ind) = cat(3, frameLayerR,frameLayerG,frameLayerB);
end

if verLessThan('matlab', '8.5')
    imgMov = immovie(imgFrames);%, map);
    movie2avi(imgMov, outFilename, 'fps', movieFps);
else
%     maxPerFrame = max(max(max(imgFrames)));
%     maxFrameSet = repmat(maxPerFrame, [size(imgFrames, 1), size(imgFrames, 2), size(imgFrames, 3), 1]);
%     imgFrames = imgFrames./mxImage;%maxFrameSet;
    outFilename(end-3:end) = '.mp4';
    movieObj = VideoWriter(outFilename);
    movieObj.FrameRate = movieFps;
    open(movieObj);
    writeVideo(movieObj, imgFrames);
    close(movieObj);
    
end