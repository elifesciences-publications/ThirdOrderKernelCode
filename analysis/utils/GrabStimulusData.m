function [allStimulusBehaviorData, allData] = GrabStimulusData(filePath, state)
% This function takes in the responseTiffpathName, which is the movpathName
% to the tiff output from scanimage, and then check to see if there's a
% stimulus_data folder. If not it will ask the user to select the folder
% created by master_stimulus that contains all this data. It will then move
% said folder to the folder with the response data and rename it
% 'stimulusData' so we have everything in one location! Later iterations
% will hopefully automatize this...

if nargin == 1
    GrabStimulusDataZ(filePath)
end
       
% grabStimpathName = fullfile(pathName, fn);       
   

if ~isdir(fullfile(filePath, 'stimulusData'))    
    dataGatherStartTime = state.internal.triggerTimeString;

    directory = uigetdir(filePath, ['File: ' name ', time: ' dataGatherStartTime]);
    destination = fullfile(filePath, 'stimulusData');
    copied = copyfile(directory, destination); % copy the file to current directory, which is what we want! :D
    if ~copied
        error(['Something''s gone wrong with copying ' directory ' to ' destination '! :O'])
    end
end

stimDataFilename = fullfile(filePath, 'stimulusData', 'textStimData.csv');
checkFile = dir(stimDataFilename);
if ~isempty(checkFile)
    stim_handle = fopen(stimDataFilename, 'r');
else
    % We changed the name of this file >.>
    stimDataFilename = fullfile(filePath, 'stimulusData', 'stimdata.csv');
    stim_handle = fopen(stimDataFilename);
end

header = fgetl(stim_handle); %Header's gonna be the first line
headerData = textscan(header, '%s', 'Delimiter', ',');
headers = headerData{1};
header_inds = find(~cellfun('isempty', headers));

fclose(stim_handle);



allData = csvread(stimDataFilename, 1, 0); %The first line's the header info

for i = 1:length(header_inds)
    start_ind = header_inds(i);
    if i == length(header_inds)
        end_ind = size(allData, 2);
    else
        end_ind = header_inds(i+1)-1;
    end
    allStimulusBehaviorData.(headers{start_ind}) = allData(:, start_ind:end_ind);
end