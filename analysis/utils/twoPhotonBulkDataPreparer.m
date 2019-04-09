function twoPhotonBulkDataPreparer(linescan, channels, varargin)
%TWOPHOTONBULKDATAPREPARER This function does a preparation for analysis of
%all files in a subdirectory. Specifically, it runs twoPhotonImageParser
%which takes care of aligning unaligned images and saving the appropriate
%*.mat file.
%   twoPhotonBulkDataPreparer(linescan, channels) run through the *.tif
%   files in the directory and subdirectories of a parent directory chosen
%   through a dialog when the function runs and pass them to
%   twoPhotonImageParser. The linescan flag tells the function whether to
%   treat these *.tif files as linescans and the channels parameter is a
%   vector of channels that need parsing from the file.
%
%   twoPhotonBulkDataPreparer(linescan, channels, 'directory',
%   parent_directory) run through the *.tif files in the directory and
%   subdirectories of the parent_directory provided and pass them to
%   twoPhotonImageParser.
%
%   twoPhotonBulkDataPreparer(..., 'recursive', [true]|false) can control
%   whether the search is recursive; default true.
%
%   *Note that this function is blind to whether or not these *.tif files
%   should actually be aligned--i.e. it'll pass zStacks in as well.
%   Fortunately the original data stays untouched.*
%
%   % Example:
%   %  Run through the *.tif files acquired by linescan in
%   %  C:/path/to/data/todaysData and prepare them for data analysis. Parse
%   % both channels 1 and 2.
%
%   parent_directory = 'C:/path/to/data/todaysData'
%   linescan = true;
%   channels = [1 2];
%   twoPhotonBulkDataPreparer(linescan, channels, 'directory', parent_directory);
directory = '';
recursive = true;

% Receive input variables
for ii = 1:2:length(varargin)
    %Remember to append all new varargins so old ones don't overwrite
    %them!
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if isempty(directory)
    directory = uigetdir;
end

if recursive
    tiffList = subdir(fullfile(directory, '*.tif'));
else
    tiffList = dir(fullfile(directory, '*.tif'));
    for i=1:length(tiffList)
        tiffList(i).name = [directory tiffList(i).name];
    end
end

for filenum = 1:length(tiffList)
    filename = tiffList(filenum).name;
    fprintf('Preparing %s\n', filename);
    for channel = 1:length(channels)
        fprintf('Analyzing and compiling channel %d\n', channels(channel));
        %No need to grab the PD data more than once...
        if channel == length(channels)
            runPDAnalysis = 'Yes';
        else
            warning('An alignment of the second channel automatically happens and you''re probably gonna regret putting in more than one channel here.');
            runPDAnalysis = 'No';
        end
        twoPhotonImageParser('filename', filename, 'linescan', linescan, 'channelDesired', channels(channel), 'runPDAnalysis', runPDAnalysis);
    end
end