function [flyResp, roiMask, extraVals] = WriteUp_T4T5_IcaRoiExtraction(backgroundSubtractedMovie,deltaFOverF,epochStartTimes,epochDurations,params,varargin)
    dFoF = deltaFOverF;
    roiSizeIcaMin = 0;% Default of 0 actually means that this won't be checked
    extraVals.defaults.roiSizeIcaMin = roiSizeIcaMin;
    
    
    %%%%%% TODO: DOWNSAMPLE CORRECTLY %%%%%%%%
    downsampled = (dFoF(1:2:end-1,1:2:end,:) + ...
                   dFoF(2:2:end  ,1:2:end,:) + ...
                   dFoF(1:2:end-1,2:2:end,:) + ...
                   dFoF(2:2:end,2:2:end,:))/4;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PCA to reduce problem dimensionalityepochsForIdentification = varargin([false strcmp(varargin, 'epochsForIdentificationForFly')]);
if nargin > 2
    epochsForIdentification = varargin([false strcmp(varargin, 'epochsForIdentificationForFly')]);
    if ~isempty(epochsForIdentification) && ~isequal(epochsForIdentification, {''})
        epochsForIdentification = epochsForIdentification{1};
        extraVals.epochsForIdentificationForFly = epochsForIdentification;
        
        firstStartTime = size(backgroundSubtractedMovie, 3);
        lastEndTime = 1;
        for i=1:length(epochsForIdentification)
            % We're assuming only two presentations of the probe at the
            % beginning here--we can look back at this to make it more
            % generic or figure out how to tell beginning probe
            % presentations from ending probe presentations
            selectedEpoch = ConvertEpochNameToIndex(params,epochsForIdentification{i});
            firstStartTime = min([firstStartTime; epochStartTimes{selectedEpoch}(1:2)]);
            lastEndTime = max([lastEndTime; epochStartTimes{selectedEpoch}(1:2)+epochDurations{selectedEpoch}(1:2)-1]);
        end
    else
        firstStartTime = 1;
        lastEndTime = size(backgroundSubtractedMovie, 3);
    end
    
    roiSizeIcaMinInput = varargin([false strcmp(varargin, 'roiSizeIcaMin')]);
    if ~isempty(roiSizeIcaMinInput)
        roiSizeIcaMin = roiSizeIcaMinInput{1};
    end
    
    flims = [firstStartTime lastEndTime];
else
    flims = [1 2085]; % ICA on probing stimulus for edge/square wave probe
end

% Save the minimum roiSize value
extraVals.roiSizeIcaMin = roiSizeIcaMin;

    nPCs = 45;
    %%%%%% TODO: GET THE EXTRACTION LIMITS FOR REAL %%%%%%%
%     flims = [55 6157];
%     flims = [55 2139];
%     flims = [1 size(dFoF, 3)];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [mixedsig, mixedfilters, CovEvals] = OmerPCA(downsampled(:,:,flims(1):flims(2)),nPCs);

    %% Choose PCs

%     figure(1);
%     % This is still ugly and broken
%     [PCuse] = OmerChoosePCs(mixedfilters, size(downsampled,1), size(downsampled,2));
    PCuse = 1:nPCs;

    %% ICA
    nIC = length(PCuse);
    mu = 0.5;

    [ica_sig, ica_filters, ica_A, icSkew, numiter] = CellsortICA(mixedsig, mixedfilters, CovEvals, PCuse, mu, nIC,[],[],1000);

    %% Upscale extracted filters to correct size
    numFilters = size(ica_filters,1);
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