function [timeByRoisAligned, roiStimIndexes, epochList] = ReadEphysRudyData(data_path)
dataRate = 10e3; % 10 kHz. Hard coded here.
amount_of_effective_photodiode_data = 4000; % one epoch has 3 flashes in general that is 166 * 3 ~ 500 + end of the parameter file. 166 * 20 ~ 3000 
% thresh_prc = 99; % 97.5 perctile as the threshold for photodiode data. 
%% path for response and stimulus.
photodiode_path = fullfile(data_path, 'ch1.ibw');
signal_path  = fullfile(data_path,'ch0.ibw');
stimPath = fullfile(data_path,'stimdata.mat');

%% ephys two channels.
signal = IBWread(photodiode_path);
photodiode_signal = signal.y;
signal = IBWread(signal_path);
response_signal = signal.y;

%% stimulus.
stimImage = load(stimPath);

%% non important parameter to be compatible with twophoton imagind code
roiCenterOfMass = [0 0];
movieSizeFull = [1 1 length(response_signal)];
linescan = 0;
highResLinesPerFrame = 1;


%% preprocessing of photodiode, make it into 1 or 0.
photodiode_sort = sort(photodiode_signal,'descend');
thresh = mean([mean(photodiode_sort(1:amount_of_effective_photodiode_data)),0]); % half of a typical photodiode signal.
photodiode_cleaned = PreprocessingPhotodiodeRudys(photodiode_signal, thresh); % filling  the dip in raw photodiode data. 


%%
[timeByRois, roiStimIndexes, epochList, ~] = MapAlignedStimulusToResponse...
    (response_signal, stimImage.stimData, data_path, roiCenterOfMass, movieSizeFull, dataRate, linescan, photodiode_cleaned, highResLinesPerFrame);
% recalculate triggerInds here.
allStimulusBehaviorData = GrabStimulusDataStructure(data_path);
triggerInds = ExtractTriggersFromPhotodiode(photodiode_cleaned, allStimulusBehaviorData, linescan , dataRate, movieSizeFull);
timeByRoisAligned = timeByRois(triggerInds(1).bounds(1,1): triggerInds(end).bounds(2,end) - 1);
end

function  photodiode_cleaned = PreprocessingPhotodiodeRudys(photodiode_signal, thresh)
    % 4 or 5....
    photodiode_bool = photodiode_signal > thresh;
    % find the first 1 after 0.
    flashing_start_time = find([0;diff(photodiode_bool)] == 1);
    % 5. filling in 5 zero.
     photodiode_cleaned = photodiode_bool;
    for ii = 1:1:length(flashing_start_time)
    photodiode_cleaned(flashing_start_time(ii) - 5: flashing_start_time(ii)) = true;
    end
    
    MakeFigure; 
    subplot(2,1,1)
    plot(photodiode_bool);
    subplot(2,1,2)
    plot(photodiode_cleaned);
end