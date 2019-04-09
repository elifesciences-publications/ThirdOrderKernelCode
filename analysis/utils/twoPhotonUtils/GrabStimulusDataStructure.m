function [allStimulusBehaviorData] = GrabStimulusDataStructure(parentDir)
% This converts the textStimData.csv file into the allStimulusBehaviorData
% structure, which separates the various portions of the file

% The below allows us to feed in either a behavior directory (where all the
% data is in the top level) or an imaging directory (where the data is
% under the stimulusData/ folder)
stimulusDataFilePath = fullfile(parentDir, 'stimulusData');
if isempty(dir(stimulusDataFilePath));
    stimulusDataFilePath = parentDir;
end

stimDataFilename = 'textStimData.csv';
stimDataFilepath = fullfile(stimulusDataFilePath, stimDataFilename);

checkFile = dir(stimDataFilepath);
if ~isempty(checkFile)
    stim_handle = fopen(stimDataFilepath, 'r');
else
    % We changed the name of this file >.>
    stimDataFilename = 'stimdata.csv';
    stimDataFilepath = fullfile(stimulusDataFilePath, stimDataFilename);
    stim_handle = fopen(stimDataFilepath);
end


header = fgetl(stim_handle); %Header's gonna be the first line
headerData = textscan(header, '%s', 'Delimiter', ',');
headers = headerData{1};
header_inds = find(~cellfun('isempty', headers));

fclose(stim_handle);



allData = csvread(stimDataFilepath, 1, 0); %The first line's the header info

for i = 1:length(header_inds)
    start_ind = header_inds(i);
    if i == length(header_inds)
        end_ind = size(allData, 2);
    else
        end_ind = header_inds(i+1)-1;
    end
    allStimulusBehaviorData.(headers{start_ind}) = allData(:, start_ind:end_ind);
end
