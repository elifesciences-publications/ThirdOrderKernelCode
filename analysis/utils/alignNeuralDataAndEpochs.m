function [resp, epochs] = alignNeuralDataAndEpochs(rawData,photoDiodeData,dataRate,frameStartTimes,rawEpochs,manualSync)

%% Align the voltage data to the stimulus using the photodiode. Now both 
 % the neural data and the frame start times start at 0.
    
    if(~manualSync)
        % Generate template of synchronization signal
        % Representation of the synchronization signal at one sample per frame
        syncWord = '0x16EE';
        syncWordBinary = double(hexToBinaryVector(syncWord,16));
        % Repeat each frame as needed to match the data rate
        signalStretchCoeff = (1/60)*dataRate;
        signal = syncWordBinary(ceil(1/(2*signalStretchCoeff):1/signalStretchCoeff:end));
        signalZeroCentered = signal - 0.5;

        % Grab first ten seconds of photodiode data
        firstTenPhoto = photoDiodeData(1:10*dataRate);
        firstTenPhotoMeanShifted = firstTenPhoto - mean(firstTenPhoto);

        % Find the offset that maximizes the crosscorrelation
        [xc,lags] = xcorr(firstTenPhotoMeanShifted,signalZeroCentered);
        [~,i] = max(abs(xc));
        bestLag = lags(i);

        % Get an absolute measure of how well this offset performs by
        % classifying signals as 1 or 0 and determining what percentage of the
        % samples match up with the template.

        matchingPhoto = firstTenPhoto(1+bestLag:length(signal)+bestLag);
        [~,centroids] = kmeans(matchingPhoto,2,'EmptyAction','singleton');
        cutoff = mean(centroids);
        binarizedPhoto = matchingPhoto > cutoff;

        matchPercent = 100*mean(binarizedPhoto(:) == signal(:));

        assert(matchPercent > 90,['Was unable to align neural data to stimulus timings. Best match: ' num2str(matchPercent) '%'])
        disp(['Found a ' num2str(matchPercent) '% timing alignment to neural data']);

        shiftedData = rawData(1+bestLag+length(signal):end);
    
    else
        shiftedData = rawData(manualSync:end);
    end
    
    
%%  Cut out the portion between the first stim presentation and the last
    % We cut out the very first data point as well because it's an
    % integration of a time region in which the stimulus was not fully
    % displayed
    resp = shiftedData(ceil(frameStartTimes(1)*dataRate)+1:ceil((frameStartTimes(end)+0.016)*dataRate));

%% Find stim data for each point in the voltage data

    % Determine the number of times each epoch value should be repeated
    scaledStartTimes = [frameStartTimes(:)' frameStartTimes(end)+0.016]*dataRate;
    numRepeats = diff(ceil(scaledStartTimes));
    
    % Perform repetition.
    
    % First remove any epochs with repetition 0
    nonZeroRepeats = numRepeats > 0;
    numRepeats = numRepeats(nonZeroRepeats);
    filteredEpochs = rawEpochs(nonZeroRepeats);
    
    % To perform repetition, we need to get repeated indicies pointing to
    % the correct locations. We will do this by creating a vector where
    % there is a 1 wherever a repeat ends and then take the cumsum of that.
    
    % The repeat end locations occur at a place that is the cumsum of all
    % previous repeats
    sumRepeats=cumsum(numRepeats);
    repeatEndLocations=zeros(1,sumRepeats(end));
    repeatEndLocations([1,sumRepeats(1:end-1)+1])=1;
    
    lookupIndexes=cumsum(repeatEndLocations);
    epochs=filteredEpochs(lookupIndexes);
end