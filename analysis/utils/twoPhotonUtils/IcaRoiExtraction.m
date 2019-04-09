function [flyResp, roiMask, extraVals] = IcaRoiExtraction(backgroundSubtractedMovie,deltaFOverF,epochStartTimes,epochDurations,params,varargin)
    roiSizeIcaMin = 0;% Default of 0 actually means that this won't be checked
    extraVals.defaults.roiSizeIcaMin = roiSizeIcaMin;
    
    
    

if nargin > 2
    epochsForIdentification = varargin([false strcmp(varargin, 'epochsForIdentificationForFly')]);
    if ~isempty(epochsForIdentification) && ~isequal(epochsForIdentification, {''})
        epochsForIdentification = epochsForIdentification{1};
        extraVals.epochsForIdentificationForFly = epochsForIdentification;
        
%         firstStartTime = size(backgroundSubtractedMovie, 3);
%         lastEndTime = 1;
        epForIdStartTimes = [];
        epForIdEndTimes = [];
        for i=1:length(epochsForIdentification)
            selectedEpoch = ConvertEpochNameToIndex(params,epochsForIdentification{i});
            if ~isnan(selectedEpoch)
                epForIdStartTimes = [epForIdStartTimes; cat(1, epochStartTimes{selectedEpoch})];
                epForIdEndTimes = [epForIdEndTimes; cat(1, epochStartTimes{selectedEpoch})+cat(1, epochDurations{selectedEpoch})-1];
            end
%             firstStartTime = min([firstStartTime; epochStartTimes{selectedEpoch}]);
%             lastEndTime = max([lastEndTime; epochStartTimes{selectedEpoch}+epochDurations{selectedEpoch}-1]);
        end
        [epForIdStartTimes, sortInds] = sort(epForIdStartTimes(:));
        epForIdEndTimes = epForIdEndTimes(:);
        epForIdEndTimes = epForIdEndTimes(sortInds);
        
        framesAnalyze = [];
        for i = 1:length(epForIdStartTimes)
            framesAnalyze = [framesAnalyze epForIdStartTimes(i):epForIdEndTimes(i)];
        end
        
        
    else
        firstStartTime = 1;
        lastEndTime = size(backgroundSubtractedMovie, 3);
        
        flims = [firstStartTime lastEndTime];
        framesAnalyze = flims(1):flims(2);
    end
    
    roiSizeIcaMinInput = varargin([false strcmp(varargin, 'roiSizeIcaMin')]);
    if ~isempty(roiSizeIcaMinInput)
        roiSizeIcaMin = roiSizeIcaMinInput{1};
    end
    
    randomNumberSeed = varargin([false strcmp(varargin, 'randomNumberSeed')]);
    if ~isempty(randomNumberSeed)
        extraVals.seed = randomNumberSeed;
        rng(randomNumberSeed);
        % We're setting whatever current the current seed is as the default
        % 
        extraVals.defaults.seed = extraVals.seed;
    else
        extraVals.seed = rng;
        extraVals.defaults.seed = extraVals.seed;
    end
    
else
    flims = [55 2139]; % ICA on probing stimulus.
    framesAnalyze = flims(1):flims(2);
end

% Save the minimum roiSize value
extraVals.roiSizeIcaMin = roiSizeIcaMin;

%% PCA to reduce problem dimensionality
    dFoF = deltaFOverF;

    %%%%%% TODO: DOWNSAMPLE CORRECTLY %%%%%%%%
    downsampled = (dFoF(1:2:end-1,1:2:end,:) + ...
                   dFoF(2:2:end  ,1:2:end,:) + ...
                   dFoF(1:2:end-1,2:2:end,:) + ...
                   dFoF(2:2:end,2:2:end,:))/4;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    nPCs = 45;
    
    [mixedsig, mixedfilters, CovEvals] = OmerPCA(downsampled(:,:,framesAnalyze),nPCs);

    %% Choose PCs

    if length(CovEvals)<nPCs
        PCuse = 1:length(CovEvals);
    else
        PCuse = 1:nPCs;
    end

    %% ICA
    nIC = length(PCuse);
    mu = 0.5;

    [ica_sig, ica_filters, ica_A, icSkew, numiter] = CellsortICA(mixedsig, mixedfilters, CovEvals, PCuse, mu, nIC,[],[],1000);

    %% Upscale extracted filters to correct size
    if roiSizeIcaMin
        numFilters = size(ica_filters,1);
    else
        numFilters = 13; % This retains prior behavior when we don't use the size min input...
    end
    [outputRows, outputCols, numTimepoints] = size(deltaFOverF);
    upscaled_ica_filters = zeros(numFilters,outputRows,outputCols);
    for ii = 1:numFilters
        upscaled_ica_filters(ii,:,:) = imresize(squeeze(ica_filters(ii,:,:)),[outputRows outputCols]);
    end
    
    %% Segment ROIs
    
    threshold = 99;
    
    splitMasks = [];
    for ii = 1:numFilters
        thisFilter = abs(squeeze(upscaled_ica_filters(ii,:,:)));
%         thisFilter = squeeze(upscaled_ica_filters(ii,:,:));
        
        % Create fully labeled watershed
%         watersheds = ones(size(thisFilter));
        watersheds = WatershedImage(thisFilter);
        
        % Create a binary mask 
        thresholdVal = prctile(thisFilter(:),threshold);
        thresholdVal = max(thresholdVal,0);
        thisFilter(thisFilter< thresholdVal) = 0;
        thisFilter(thisFilter>=thresholdVal) = 1;
        thisShedSet = thisFilter .* watersheds;
        
        % Put each region in a separate mask
        uniqueVals = unique(thisShedSet(:));
        uniqueVals = uniqueVals(uniqueVals ~= 0);
        for i = 1:length(uniqueVals)
            r = uniqueVals(i);
            thisSplitMask = thisShedSet == r;
            roiSize = sum(thisSplitMask(:));
            if roiSizeIcaMin && roiSize < roiSizeIcaMin
                continue
            end
            splitMasks = cat(3,splitMasks,thisSplitMask);
        end
    end
    
    % Handle overlapping ROIs
    % Assign each mask a unique prime
    primes = GenerateNPrimes(size(splitMasks,3));
    primes = permute(primes,[3 1 2]);
    primeMasks = bsxfun(@times,primes,splitMasks);

    % Multiply primes together to get a unique number whenever ROIs overlap
    primeMasks(primeMasks == 0) = 1;    
    combinedMask = prod(uint64(primeMasks),3);
    combinedMask(combinedMask == 1) = 0;
    
    % Reduce the range of the label indicies to the number of unique ROIs
    uniqueVals = unique(combinedMask(:));
    uniqueVals = uniqueVals(uniqueVals ~= 0);
    numRois = length(uniqueVals);
    roiMask = zeros(size(combinedMask));
    for ii = 1:numRois
        roiMask(combinedMask == uniqueVals(ii)) = ii;
    end
    
    
    %% Get ROI responses
    deltaFFlattened = reshape(deltaFOverF,outputRows*outputCols,numTimepoints);
    flyResp = zeros(numTimepoints,numRois);
    for ii = 1:numRois
        selection = (roiMask == ii);
        flyResp(:,ii) = mean(deltaFFlattened(selection(:),:),1)';
    end
    
    %% Make some plots
    MakeFigure;
    numFilters = size(upscaled_ica_filters,1);
    numPlotCols = ceil(sqrt(numFilters));
    for ii = 1:numFilters
        subplot(numPlotCols,numPlotCols,ii);
        imagesc(squeeze(upscaled_ica_filters(ii,:,:)));
    end
    
    MakeFigure;
    roiColors = label2rgb(roiMask,'jet','k');
    meanLuminance = mean(backgroundSubtractedMovie,3);
    minLuminance = min(min(meanLuminance));
    maxLuminance = max(max(meanLuminance));
    meanLuminance = 255*(meanLuminance-minLuminance)/(maxLuminance-minLuminance);
    meanLuminance = cat(3,meanLuminance,meanLuminance,meanLuminance);
    combined = 0.5*double(roiColors) + 0.5*meanLuminance;
    imagesc(uint8(combined));
    
    MakeFigure;
    plot(icSkew);
    
    if ~exist('extraVals', 'var')
        extraVals = [];
    end
end