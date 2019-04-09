function [outRois,outMask, extraVals] = PixelRoiSelection(~,deltaFOverF,epochStartTimes,epochDurations,params,varargin)
    roiSizeMin = 100;
    roiSizeMax = inf;

    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    epochsForIdentification = varargin([false strcmp(varargin, 'epochsForIdentificationForFly')]);
    if isempty(epochsForIdentification)
        error('PixelRoiSelection requires an epochsForIdentification varargin!')
    else
        epochsForIdentification = epochsForIdentification{1};
        extraVals.epochsForIdentificationForFly = epochsForIdentification;
    end
    
    movieSize = size(deltaFOverF);

    % convert epochsForSelection from string to index
    selectedEpochs = ConvertEpochNameToIndex(params,epochsForIdentification);
   
    %% make a functional mask by comparing responses from two epochs
    epochRespA = GetMeanResponsesFromMovie(deltaFOverF,epochStartTimes,epochDurations,selectedEpochs(1));
    epochRespB = GetMeanResponsesFromMovie(deltaFOverF,epochStartTimes,epochDurations,selectedEpochs(2));
    
    filterStd = 2;
    numStd = 3;
    x = (-numStd*filterStd):(numStd*filterStd);
    y = ((-numStd*filterStd):(numStd*filterStd))';
    maskFilter = normpdf(y,0,filterStd)*normpdf(x,0,filterStd);
    
    % average over trials
    epochRespA = mean(epochRespA,3);
    epochRespB = mean(epochRespB,3);
    
    % filter the average responses in space to get rid of noise
    epochRespA = imfilter(epochRespA,maskFilter,'symmetric');
    epochRespB = imfilter(epochRespB,maskFilter,'symmetric');
    
    functionalMask = epochRespA - epochRespB;

    %% threshold mask
    maskThreshPercent = 95;
    maskList = reshape(functionalMask,[numel(functionalMask) 1]);
    maskThresh = prctile(maskList,maskThreshPercent);
    
    finalMask = functionalMask>maskThresh;
    
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
    imagesc(epochRespA);
    ConfAxis('fTitle',['response to epoch #' selectedEpochs(1)]);
    subplot(2,2,2);
    imagesc(epochRespB);
    ConfAxis('fTitle',['response to epoch #' selectedEpochs(2)]);
    subplot(2,2,3);
    imagesc(functionalMask);
    ConfAxis('fTitle',['epoch #' selectedEpochs(1) 'minus epoch #' selectedEpochs(2)]);
    subplot(2,2,4);
    imagesc(outMask);
    ConfAxis('fTitle','selectedRois');
end