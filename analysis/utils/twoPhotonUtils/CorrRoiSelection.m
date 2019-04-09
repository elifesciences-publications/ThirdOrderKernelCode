function [outRois,outMask] = CorrRoiSelection(rawMovie,deltaFOverF,epochStartTimes,epochDurations,epochsForSelection,params,varargin)
    roiSizeMin = 100;
    roiSizeMax = inf;
    interleaveEpoch = params(end).nextEpoch;
    
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    movieSize = size(deltaFOverF);

    % convert epochsForSelection from string to index
    selectedEpochs = ConvertEpochNameToIndex(params,epochsForSelection);
   
    %% get correlation mask
    % correlate every trial the fly has to each epoch. we expect rois that
    % are actually responding to be correlated between trials
    numEpochs = length(params);
    corrMap = zeros(movieSize(1),movieSize(2));
    interleaveEpoch = params(end).nextEpoch;
    numEpochsIncluded = 0;
    
    totalEpochTime = tic;
    for ee = 1:numEpochs
        indEpochTime = tic;
        
        if (length(epochStartTimes{ee}) > 1) && (ee ~= interleaveEpoch)
            timeTraces = GetTimeTracesFromMovie(deltaFOverF,epochStartTimes,epochDurations,ee);
            averagedTrials = mean(timeTraces,3);
            averagedTrialsAndTime = mean(averagedTrials,1);

            squaredDeviationFromAveragedTrials = sum(sum(bsxfun(@minus,timeTraces,averagedTrials).^2,1),3);
            squaredDeviationFromAveragedTrialsAndTime = sum(sum(bsxfun(@minus,timeTraces,averagedTrialsAndTime).^2,1),3);

            r2 = 1-squaredDeviationFromAveragedTrials./squaredDeviationFromAveragedTrialsAndTime;

            corrMap = corrMap + reshape(r2,[movieSize(1) movieSize(2)]);

            numEpochsIncluded = numEpochsIncluded + 1;
        end
        
        disp(['epoch #' num2str(ee) ' took ' num2str(toc(indEpochTime)) ' seconds']);
    end
    
    corrMap = corrMap/numEpochsIncluded;
%     filteredCorrMap = imfilter(corrMap,spatialFilter,'symmetric');
    disp(['total correlation time was ' num2str(toc(totalEpochTime)) ' seconds']);
    
    %% threshold mask
    maskThreshPercent = 90;
    maskList = reshape(corrMap,[numel(corrMap) 1]);
    maskThresh = prctile(maskList,maskThreshPercent);
    
    finalMask = corrMap>maskThresh;
    
    %% apply ROI mask
    connectedRegions = bwconncomp(finalMask);
    outRois = zeros(movieSize(3),connectedRegions.NumObjects);
    outMask = zeros(movieSize(1),movieSize(2));
    roisToUse = true(1,connectedRegions.NumObjects);
    
    for cc = connectedRegions.NumObjects:-1:1
        if length(connectedRegions.PixelIdxList{cc}) > roiSizeMin && length(connectedRegions.PixelIdxList{cc}) < roiSizeMax
            mask = false(movieSize(1),movieSize(2));
            mask(connectedRegions.PixelIdxList{cc}) = true;
            selectedPixels = deltaFOverF(repmat(mask,[1 1 movieSize(3)]));
            selectedPixels = reshape(selectedPixels,[sum(sum(mask)) movieSize(3)]);
            outRois(:,cc) = mean(selectedPixels,1);

            outMask(connectedRegions.PixelIdxList{cc}) = cc;
        else
            roisToUse(cc) = false;
        end
    end
    
    outRois = outRois(:,roisToUse);
    
    %% do some plotting
    MakeFigure;
    subplot(2,2,1);
    imagesc(mean(rawMovie,3));
    ConfAxis('fTitle','mean raw movie');
    subplot(2,2,2);
    imagesc(corrMap);
    ConfAxis('fTitle','correlation map');
    subplot(2,2,3);
    imagesc(finalMask);
    ConfAxis('fTitle','final mask');
    subplot(2,2,4);
    imagesc(outMask);
    ConfAxis('fTitle','selectedRois');
end