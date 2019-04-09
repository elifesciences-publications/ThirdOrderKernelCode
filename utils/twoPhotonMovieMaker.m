function Z = twoPhotonMovieMaker(Z)
%Function asks the user for a tif input file (one taken from a loop grab of
%scanimage) and outputs an AVI file that puts together all the images
%grabbed in the loop like a movie.

%Varargin defaults!
movieFps = []; %becomes capture frame rate if nothing else is assigned to it
fnEnd = '';
    
% Receive input variables
loadFlexibleInputs(Z);

[imgFramesInit, imgData] = twoPhotonImageParser(Z);
imgFrames = zeros(size(imgFramesInit, 1), size(imgFramesInit, 2), 3, size(imgFramesInit, 3));
imgFramesInit = imgFramesInit/(mean(imgFramesInit(:))+3*std(imgFramesInit(:)));




if isempty(movieFps)
    %Grab frame rate that capture occurred at
    fpsCell = regexp(imgData.description, 'frameRate=(\d+.*\d+)', 'tokens');
    fpsSmallCell = [fpsCell{~cellfun('isempty', fpsCell)}];
    movieFps = str2double(fpsSmallCell{:});
end
if ~isempty(fnEnd)
    %DAT UNDAHSCO'!
    fnEnd = ['_' fnEnd];
end

outFilename = fullfile(Z.params.pathName, [Z.params.name, fnEnd, '.avi']); %default output filename

%Gotta reconvert imgFrames to a 4D with each 4th dimension being a 3D
%frame
for ind = 1:size(imgFramesInit, 3);
    if ~mod(ind, 100)
        disp(['Making frame ' num2str(ind)])
    end
    imgFrames(:, :, :, ind) = cat(3, imgFramesInit(:,:,ind),imgFramesInit(:,:,ind),imgFramesInit(:,:,ind));
end

if verLessThan('matlab', '8.5')
    imgMov = immovie(imgFrames);%, map);
    movie2avi(imgMov, outFilename, 'fps', movieFps);
else
%     maxPerFrame = max(max(max(imgFrames)));
%     maxFrameSet = repmat(maxPerFrame, [size(imgFrames, 1), size(imgFrames, 2), size(imgFrames, 3), 1]);
    imgFrames = imgFrames./max(imgFrames(:));%maxFrameSet;
    outFilename(end-3:end) = '.mp4';
    movieObj = VideoWriter(outFilename);
    movieObj.FrameRate = movieFps;
    open(movieObj);
    writeVideo(movieObj, imgFrames);
    close(movieObj);
    
end