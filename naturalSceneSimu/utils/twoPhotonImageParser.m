function [imgFrames, imgData, alignmentData] = twoPhotonImageParser(Z)
%This function takes in a tif image that has been output by the scanimage
%grab/loop utility and parses through it to return a 3D array where the 3rd
%dimension contains the image data of each frame. It also returns the
%original filename and pathName so that upstream functions can make new
%filenames with similar names. If you include an argument, it will use it
%as the filename of the file to open

force_reevaluation = false;
boundImageIntensity = false;
saveMat = true;
align = true;
splitImage = false;
linescan = false;
frameGrab = false;
alignmentData = [];
pathName = [];

loadFlexibleInputs(Z)

if splitImage
    saveMat = false;
end

% entryDirectory = cd;

% if ~exist('channelDesired', 'var')
if ~isfield('imageDescription', Z.params)
    %tifInf is a structure with various useful information points (including
    %all the metadata from scanimage), but currently we're just using it to see
    %how many frames were taken
    tifInf = imfinfo([pathName fn]);
    
    %Here we're going to assume that all the frames in a TIF file come from one
    %image grab--this means that the generic info of what frames were being
    %grabbed will remain the same, so we can just grab it from the first
    %structure in tifInf and put it in a cell;
    tifInfDescription = strsplit(tifInf(1).ImageDescription, sprintf('\r'));
    imgData.description = tifInfDescription;
else
    imgData.description = Z.params.imageDescription;
    tifInfDescription = Z.params.imageDescription;
end
acquiredChannelCell = regexp(tifInfDescription, 'saving.*(\d+)=[^0]', 'tokens');

acquiredChannels = [acquiredChannelCell{~cellfun('isempty', acquiredChannelCell)}];

%If there are 3 acquired channels, each frame of a given channel will be 2
%away from the next one, because there are another two frames from the
%other two channels; thus you take every third frame (so frameSpacing=3)
frameSpacing = length(acquiredChannels);

% I hate the hardcoding, but there should only be a channel 3 if the
% photodiode data is being acquired, so this segment handles that
if any(strcmp([acquiredChannels{:}], '3'))
    if ~exist('runPDAnalysis', 'var')
        runPDAnalysis = questdlg('Do you want to extract the photodiode data as well?', '', 'Yes', 'No', 'Yes');
    end
    PDind = find(strcmp([acquiredChannels{:}], '3'));
end


%THIS WON'T WORK if the it's not the last channel; which it kind of always
%will be. 'Always'. Hopefully...
if strcmp(runPDAnalysis, 'Yes')
    acquiredChannels(strcmp([acquiredChannels{:}], '3')) = [];
end

if frameSpacing>1
    if ~exist('channelDesired', 'var')
        channelDesired = questdlg('Which channel are you interested in?', 'Choose a channel', acquiredChannels{:}, acquiredChannels{end});
        % Rest of the code expects a string, not a cell
        channelDesired = channelDesired{1};
    end
    if strcmp(channelDesired, 'all')
        % if one wants all the frames, you do no frame spacing and you
        % start at index one. This'll packet them all nicely (say, both
        % PMTs as well as the PD) so that you can manipulate the entire
        % image
        frameSpacing = 1;
        indChoice = 1;
    else
        % This little bit allows the user to input a double as the channel
        % desired
        if isnumeric(channelDesired)
            channelDesired = num2str(channelDesired);
        end
        %The frames in a multichannel tif are saved in order of channel, so if
        %you've saved channels 1, 3, and 4 and want channel 3, you start at the
        %second index and go from there in steps of frame spacing (see the for
        %loop below)
        indChoice = find(strcmp([acquiredChannels{:}], channelDesired));
        if isempty(indChoice)
            error('psycho5:twoPhotonImageParser:channelNotFound', 'Channel %s not present as an acquired channel; if you selected the channel from the dialog, bigger issues exist... o.O', channelDesired)
        end
    end
else
    %Otherwise the beginning of one channel is the first index
    indChoice = 1;
    channelDesired = '1';
end
% elseif isnumeric(channelDesired)
%     channelDesired = num2str(channelDesired);
% end

matFiles = dir('*.mat');
% parentDir comes in two parts for those paramfiles that have '.' in their
% name which causes the rest to be parsed as an extension. We also have to
% get rid of the filesep character in pathName to have it correctly parse the
% last folder

[~, parentDir1, parentDir2] = fileparts(pathName(1:end-1));
dirCorrect = strcmp(name, [parentDir1 parentDir2]);
dirChange = false;
if ~any(strcmp([name '.mat'], {matFiles.name}))
    if ~frameGrab && ~dirCorrect
        dirExist = isdir([pathName name]);
        if dirExist
            %If the directory exists, make sure the image has been
            %appropriately moved
            files = dir([pathName name]);
            if ~any(strcmp(fn, {files.name}))
                dirChange = true;
            end
        else
            %Make a directory to store all the data if it doesn't exist
            mkdir([pathName name]);
            dirChange = true;
        end
    end
elseif ~force_reevaluation
    %If we have a *.mat file with all the data stored, just load up the
    %relevant variables and break!
    load([name '.mat'], ['imgFrames_ch' channelDesired], 'imgData');
    %     cd(entryDirectory)
    
    if exist(['imgFrames_ch' channelDesired], 'var')
        eval(['imgFrames = imgFrames_ch' channelDesired ';']);
    end
    
    if exist('imgFrames', 'var') && exist('fn', 'var') && exist('pathName', 'var') && exist('imgData', 'var')
        if align
            alignmentData = dlmread(fullfile(pathName, [name '_ch' channelDesired '_disinterleaved_alignment.txt']), '\t');
        end
        return
    end
end

%analysis_fn will point to the _disinterleaved_aligned.tif (or
%_tocoords.tif) version of the file UNLESS alignment isn't happening; this
%condition can easily be checked because that's the ONLY case in which
%analysis_fn and fn will be equivalent
analysis_fn = fn;
alignFnEnd = {[name '_ch' channelDesired '_disinterleaved_aligned'], [name '_ch' channelDesired '_disinterleaved_tocoords']};

tifFiles = dir('*.tif');
file_exists = [strfind({tifFiles.name}, alignFnEnd{1}), strfind({tifFiles.name}, alignFnEnd{2})];
aligned = false;
if any([file_exists{:}])
    % This could probably be clearer. Find where the file_exists isn't
    % empty; the first half of the values match with the first index of
    % alignFnEnd, and the second half with the second index. Make it either
    % 1 or 2 by dividing by the length and multiplying by 2 (making
    % everything on the latter half >1). Ceil it and you got it!
    analysis_fn = alignFnEnd{ceil(2*find(~cellfun('isempty', file_exists))/length(file_exists))};
    
    analysis_fn = [analysis_fn '.tif'];
    aligned = true;
    dirChange=false;
end

if ~frameGrab
    if dirChange
        fprintf('Moving acquisition to its own folder.\n')
        %Copy over the image
        movefile(fn, [pathName name])
        %Update the pathName now that the file's been moved
        pathName = fullfile(pathName, name);
        if pathName(end) ~= filesep
            pathName(end+1) = filesep;
        end
    end
end

cd(pathName)


% Align the images! But not the linescanned ones for the moment; we'll wait
% until we've grabbed the image frames to do that (so we don't grab the
% image frames twice!)
if ~linescan && ~splitImage && align && ~aligned
    fprintf('Aligning non-linescan image.\n')
    % We 'overwrite' what the channelDesired value may have been when
    % originally called so that we can include channels chosen by the
    % dialog or forced to 1; it shouldn't matter otherwise
    [analysis_fn] = alignAcquisition(pathName, fn, 'linescan', Z.params.linescan, 'channelDesired', channelDesired);
    aligned = true;
end

if strcmp(runPDAnalysis, 'Yes')
    PDdiff = indChoice-PDind;
end

%We need a frame to get the size for preallocations
testFrame = imread([pathName fn]);

imgFrames = zeros(size(testFrame, 1), size(testFrame, 2), length(indChoice:frameSpacing:length(tifInf)), 'uint16');
PDFrames = zeros(size(testFrame, 1), size(testFrame, 2), length(indChoice:frameSpacing:length(tifInf)), 'uint16');

%Something about how scanimage saves files makes there be a null byte issue
%for the ImageDescription tag; as this doesn't seem to affect anything,
%turning off the warning should speed up processing
warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');

if strcmp(runPDAnalysis, 'Yes')
    fprintf('Reading in acquisition and photodiode data.\n')
else
    fprintf('Reading in acquisition data.\n')
end
%Remember that fn and analysis_fn are equivalent ONLY when no alignment has
%been done; at this point, the old fashioned way of processing PMT/PD data
%works
if strcmp(fn, analysis_fn)
    frameNum = 1;
    TifLink = Tiff([pathName fn], 'r');
    
    
    %We only go through frameSpacing frames because that's what the desired PMT
    %is from
    fprintf('%4d%% done', 0)
    for i= indChoice:frameSpacing:length(tifInf)
        percentDone = round(100*(i-indChoice+1)/(length(tifInf)-frameSpacing));
        %         fprintf('\b\b\b\b\b\b\b\b\b\b');
        fprintf('\b\b\b\b\b\b\b\b\b\b%4d%% done', percentDone)
        TifLink.setDirectory(i);
        imgFrames(:, :, frameNum) = TifLink.read();
        if strcmp(runPDAnalysis, 'Yes')
            TifLink.setDirectory(i-PDdiff);
            PDFrames(:, :, frameNum) = TifLink.read();
        end
        frameNum = frameNum + 1;
    end
    fprintf('\n');
    TifLink.close();
    %Linescans get aligned here because the frames are needed and we might
    %as well only grab them once
    if linescan && ~splitImage && align && ~aligned
        fprintf('Aligning linescan image.\n')
        imgFrames = alignAcquisition(pathName, fn, 'linescan', Z.params.linescan, 'imgFrames', imgFrames, 'channelDesired', channelDesired);
    end
%HOWEVER if they're different we need to process image data from
%analysis_fn and PD data from fn (because the image remains disinterleaved
%after alignImages.ijm is run on it in ImageJ)
else
    TifLinkImage = Tiff([pathName analysis_fn], 'r');
    
    numSlicesCell = regexp(TifLinkImage.getTag('ImageDescription'), 'slices=(\d+)', 'tokens');
    numSlices = str2double(numSlicesCell{1}{1});
    
    fprintf('Data read: ')
    fprintf('%4d%% done', 0)
    for i = 1:numSlices
        %         fprintf('\b\b\b\b\b\b\b\b\b\b');
        fprintf('\b\b\b\b\b\b\b\b\b\b%4d%% done', round(100*i/numSlices))
        TifLinkImage.setDirectory(i)
        imgFrames(:, :, i) = TifLinkImage.read();
    end
    fprintf('\n');
    TifLinkImage.close();
    
    if strcmp(runPDAnalysis, 'Yes')
        TifLinkPDData = Tiff([pathName fn], 'r');
        frameNum = 1;
        fprintf('Photodiode read: ')
        fprintf('%4d%% done', 0)
        for i = PDind:frameSpacing:length(tifInf)
            fprintf('\b\b\b\b\b\b\b\b\b\b%4d%% done', round(100*i/length(tifInf)))
            PDFrames(:, :, frameNum) = imread([pathName fn], i, 'Info', tifInf);
            frameNum = frameNum + 1;
        end
        fprintf('\n');
        TifLinkPDData.close();
    end
    
end

%Gotta convert these variables into double format to allow later processing
%(think means)
imgFrames = double(imgFrames);
PDFrames = double(PDFrames);

% Grab the alignment data now that we've aligned!
if align
    alignmentData = dlmread(fullfile(pathName, [name '_ch' channelDesired '_disinterleaved_alignment.txt']), '\t');
end

% frameNum = 1;
% for i = indChoice:frameSpacing:length(tifInf)
%     currFrame = double(imread([pathName fn], 'Index', i));
%     imgFrames(:, :, frameNum) = currFrame;
%     if strcmp(runPDAnalysis, 'Yes')
%         currPDframe = double(imread([pathName fn], 'Index', i-PDdiff));
%         PDFrames(:, :, frameNum) = currPDframe;
%     end
%     frameNum = frameNum + 1;
% end

imgData.PDFrames = PDFrames;

%Grab the maximum overall value for normalizing
% mxVal = max(imgFrames(:));
%
% imgFrames = imgFrames/mxVal; %normalize to 1

if boundImageIntensity
    %J/k! We actually want to get rid of those pesky super bright pixels that
    %overshadow all other information
    mxImg = max(imgFrames(:));
    statImgFrames = ceil(imgFrames/mxImg*100)/100;
    %The rounded numbers will be in increments of .01 from 0 to 1, so these are
    %all the unique values
    unq = 0:.01:1;
    numElems = zeros(size(unq));
    for i = 1:length(unq)
        numElems(i) = sum(statImgFrames(:)==unq(i));
    end
    
    %Find the value above which no bin contains more than one percent of the
    %pixels; move one to the right of that because you're taking everything
    %bigger and start at rounded to 0...
    thresholdIndex = find(numElems>.06*sum(numElems), 1, 'last')+1;
    if thresholdIndex <= length(unq);
        threshold = unq(thresholdIndex);
        imgFrames(statImgFrames > threshold) = threshold*mxImg;
    end
    
    %Normalize to the new, lower threshold
    imgFrames = imgFrames/threshold;
end


if saveMat
    fprintf('Saving *.mat file with unwrapped acquisition data...')
    %Get into the new directory and save the mat file
    cd(pathName)
    saveVariables.(['imgFrames_ch' channelDesired]) = imgFrames;
    saveVariables.fn = fn;
    saveVariables.pathName = pathName;
    saveVariables.imgData = imgData;
    saveOrAppendMatFile([name '.mat'], saveVariables)
    fprintf(' done.\n')
else
    fprintf('Saving empty *.mat file to acknowledge acquisition folder...')
    cd(pathName)
    %Save an empty folder so that we actually avoid creating subfolders,
    %etc. once the image has been saved in its folder
    saveVariables = struct();
    saveOrAppendMatFile([name '.mat'], saveVariables)
    fprintf(' done.\n')
end

%Make sure to return to the expected directory
%Actually... not for now... other functions should just use the output
%variables and not need a directory... (unless outputting, in which case we
%want it in this new directory)
% cd(entryDirectory)

