function [processedMovie, movieSize, extraValsOut] = LoadAndProcessMovieData(dataPathIn, alignmentData, zoomLevel, linescan, filterMovie, backgroundSubtractMovie, useAlignedData, percMotionThresh, varargin)

plotMask = true;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

movieLoadTime = tic;
moviePath = fullfile(dataPathIn,'alignedMovie.mat');
unalignedMoviePath = fullfile(dataPathIn,'unalignedMovie.mat');

imgDataPath = fullfile(dataPathIn, 'imageDescription.mat');
imgData = load(imgDataPath, 'state'); % To be used for determining what channels should be in movieData...

if useAlignedData
    
    movieData = load(moviePath);
    if isfield(movieData, 'imgFrames_ch1')
        movieData = double(movieData.imgFrames_ch1);
    else isfield(movieData, 'imgFrames_ch2')
        movieData = double(movieData.imgFrames_ch2);
    end
    
    if linescan && size(movieData, 1) ~= 1
        movieData = permute(movieData, [2 1 3]);
        movieData = reshape(movieData, 1, size(movieData, 1), []);
    end
    
    movieSize = size(movieData);
    
    % Get alignment information for window mask creation
    filesInMainDirectory = dir(dataPathIn);
    fileNames = {filesInMainDirectory.name};
    
    if nargin>1 && ~isempty(alignmentData) && ~isempty(zoomLevel)
        movieMask = CalculateWindowMask(movieSize, alignmentData, zoomLevel, plotMask, linescan, percMotionThresh);
    else
        movieMask = ones(movieSize(1:2));
    end
    
    %             % remove the parts of the movie from the alignment mask
    %             maskPath = fullfile(dataPath{ff},'movieMask.mat');
    %             movieMask = load(maskPath);
    %             movieMask = movieMask.windowMask;
    [top,left] = find(movieMask,1,'first');
    [bottom,right] = find(movieMask,1,'last');
    movieIn = movieData(top:bottom,left:right,:);
else
    if exist(unalignedMoviePath,'file')==2
        movieIn = load(unalignedMoviePath);
        movieIn = movieIn.movieIn;
    else
        originalDataPath = DirRec(dataPathIn{ff},'.tif');
        [~,thisFile] = fileparts(originalDataPath{1});
        moviePath = fullfile(dataPathIn{ff},[thisFile '.tif']);
        
        movieIn = LoadTiffStack(moviePath,[1 2]);
        save(unalignedMoviePath,'movieIn','-v7.3');
    end
    
    movieSize = size(movieIn);
end

disp(['loading movie took ' num2str(toc(movieLoadTime)) ' seconds']);

clear('movieData');

% background subtract movie
if backgroundSubtractMovie == 1
    backgroundSubtractedMovie = BackgroundSubtract(movieIn);
elseif backgroundSubtractMovie == 2
    backgroundSubtractedMovie = BackgroundSubtractRegions(movieIn);
else
    backgroundSubtractedMovie = movieIn;
end

clear('movieIn');





%% filter movie


if filterMovie
    stDev = 1;
    numStd = 2;
    
    x = (-numStd*stDev):(numStd*stDev);
    y = ((-numStd*stDev):(numStd*stDev))';
    filtX = normpdf(x,0,stDev);
    filtY = normpdf(y,0,stDev);
    spatialFilter = filtY*filtX;
    processedMovie = imfilter(backgroundSubtractedMovie,spatialFilter,'symmetric');
else
    processedMovie = backgroundSubtractedMovie;
end

extraValsOut.filterMovie = filterMovie;
extraValsOut.backgroundSubtractMovie = backgroundSubtractMovie;
extraValsOut.useAlignedData = useAlignedData;
