function [timeByRois,watershededMean,extraVars] = watershedRoiExtraction_v2(filteredMovie,deltaFOverF,epochStartTimes,epochDurations,params,varargin)
    %% Defaults
    fgThresh = .75;
    wiThresh = .75;
    minPixNum = 20;
    cutWithinROI = true;
    threshWithinROI = .5;
    backgroundSubtractRegions = 0;
    
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end

    if any(strcmp(varargin, 'filterWatershed'))
       % extraVars.filterWatershed = varargin{[false strcmp(varargin, 'filterWatershed')]};
    else
        %extraVars.filterWatershed = false;
    end
    
    extraVars = {};
    
    %% Background selection - dim connected region
%     bkgdMask = roiUtils_dimConnectedBg( Z );
    % Update the windowMask so that background regions are excluded from
    % all future selection. 
%     Z.grab.windowMask = Z.grab.windowMask .* ~bkgdMask;
    
    %% Watershedding
    %watershededMean = roiUtils_watershedMovieAvg( Z, fgThresh );
    
    meanImg = mean(filteredMovie,3);
    watershededMean = WatershedImage(meanImg);
    
    %% Compute the brightest pixels within each ROI
%     meanImg = mean(Z.grab.imgFrames,3) .* Z.grab.windowMask;
  
    meanImgRestrict = meanImg(:);
    meanImgRestrict = meanImgRestrict(find(meanImgRestrict ~= 0));
    fgThreshVal = percentileThresh( meanImgRestrict, fgThresh );
    fgThreshMask = double( meanImg >= fgThreshVal );
%     fgThreshMask = fgThreshMask .* Z.grab.windowMask;
    for q = 1:max(watershededMean(:))
        % Pick out the mask for this watershed, dot into meanImg
        % Restrict away zero values so that percentile can be accurately
        % calculated
        thisShed = double( watershededMean == q );
        shedMask(:,:,q) = thisShed;
        shedAct(:,:,q) = meanImg .* thisShed;
        shedActRestrict = shedAct(:,:,q);
        shedActRestrict = shedActRestrict(:);
        shedActRestrict = shedActRestrict(find(shedActRestrict ~= 0));
        shedMeans(:,:,q) = mean(shedActRestrict);
        % Throw away empty levels; keep watershed pixels that are either
        % above the internal threshold or bright relative to the image as a
        % whole
        if sum(shedActRestrict) ~= 0
            withinThresh = percentileThresh( shedActRestrict, wiThresh );
            cutSheds(:,:,q) = double(((shedAct(:,:,q) >= withinThresh) + ...
                (shedAct(:,:,q) .* fgThreshMask)) > 0);
        else
            cutSheds(:,:,q) = zeros(size(meanImg));
        end
        sizeSheds(:,q) = sum(sum(cutSheds(:,:,q)));
    end

    %% Throw out small rois
    % Throw out ROIs that don't have a minPixNum "useful pixels"
    % The number of useful pixels in an ROI is determined by a combination
    % of its original size and the fgThresh. Pixels are retained for
    % being large within their ROI OR for being intense relative to the
    % mean image. So here, ROIs are discarded for being small in size, but
    % retained if a high fraction of their pixels are very bright. Not yet
    % clear that this is the most perfect way to do it but this is what
    % seems to make sense given how the previous code has been written.
    
    keepInds = find(sizeSheds > minPixNum);
    cutSheds = cutSheds(:,:,keepInds);
    shedMeans = shedMeans(:,keepInds);
    shedAct = shedAct(:,:,keepInds);
    sizeSheds = sizeSheds(keepInds);   
    cutShedsMask = sum(cutSheds,3);

    %% Make masks and vectors
    strongShedsMask = cutSheds;
%     nSheds = size(strongShedsMask,3);
%     % Make background last mask
%     strongShedsMask = cat(3,strongShedsMask,bkgdMask);
    
    for k = 1:size(strongShedsMask, 3)
        newstrongShedsMask(:, :, k) = strongShedsMask(:, :, k)*k;
    end
    watershededMean = sum(newstrongShedsMask, 3);
    numRois = max(max(watershededMean));
    movieMatrix = reshape(deltaFOverF,[numel(meanImg) size(filteredMovie,3)])';
        
    
    
    % manually select any ROIs that obviously aren't part of the structure
    [ROICOM, roiMasks] = getROICOM(watershededMean);
    fprintf('Select the ROIs to be excluded. Press enter when done.');
    tp_plotROIs_v2(filteredMovie, roiMasks, ROICOM);
    [x,y] = ginput;
    
    % determine which ROIs were selected by finding closest ROI center of
    % mass
    distanceSquared = zeros(length(x), numRois);
    ROIsFound = zeros(length(x), 1);
    for m = 1:length(x)
        for n = 1:numRois
            distanceSquared(m, n) = (x(m)-ROICOM(n, 2))^2 + (y(m)-ROICOM(n, 1))^2;
        end
        [c d] = find(distanceSquared(m, :) == min(distanceSquared(m, :)));
        ROIsFound(m, 1) = d;
    end
    ROIsFound;
    
    for k = 1:length(ROIsFound)
        watershededMean(watershededMean == ROIsFound(k)) = 0;
    end
    roiNums = unique(watershededMean);
    ROICOM(ROIsFound, :) = [];
    
    numRois = length(unique(watershededMean))-1;
    roiNums = unique(roiNums(2:end));
    j = 1;
    for k = 1:length(roiNums)
        watershededMean(watershededMean == roiNums(k)) = j;
        j = j+1;
    end

    timeByRois = zeros(size(filteredMovie,3),numRois);
    for rr = 1:numRois
        thisRoiMask = watershededMean == rr;
        thisRoiMask = reshape(thisRoiMask,[1 numel(thisRoiMask)]);
        timeByRois(:,rr) = mean(movieMatrix(:,thisRoiMask),2);
    end
    
    if backgroundSubtractRegions == 1
        meanMovie = mean(filteredMovie,3);
        movieSize = size(filteredMovie);
    
        dimThreshLevel = .05;

    
    dimThresh = percentileThreshMatrix(meanMovie,dimThreshLevel);
    dimPixels = meanMovie < dimThresh; 
    dimConnectedRegions = bwconncomp(dimPixels);
    
    %% Find largest connected dim region
    regionMap = zeros(movieSize(1),movieSize(2));
    if ~isempty(dimConnectedRegions.PixelIdxList)
        largest = length(dimConnectedRegions.PixelIdxList{1});
        largestID = 1;
        for q = 2:dimConnectedRegions.NumObjects
            if length(dimConnectedRegions.PixelIdxList{q}) > largest
                largest = length(dimConnectedRegions.PixelIdxList{q});
                largestID = q;
            end
        end
        regionMap(dimConnectedRegions.PixelIdxList{largestID}) = 1;
    end
    
    % Find dim pixels for each y-range to subtract from each ROI

    minRow = 1;
    maxRow = size(meanMovie, 1);
    minCol = 1;
    maxCol = size(meanMovie, 2);
    backgroundMasksPerY = {};

    dimThreshLevel = 0.05;
    m = 1;
    for k = minRow:10:maxRow
        regionMap2 = zeros(movieSize(1),movieSize(2));
        if k+9 <= maxRow
       dimThresh = percentileThreshMatrix(meanMovie(k:k+9, :),dimThreshLevel);
        dimPixels = meanMovie < dimThresh; 
        dimPixels([1:k-1, k+9:end], :) = 0;

        dimConnectedRegions = bwconncomp(dimPixels);
        regionMap = zeros(movieSize(1),movieSize(2));
        if ~isempty(dimConnectedRegions.PixelIdxList)
        largest = length(dimConnectedRegions.PixelIdxList{1});
        largestID = 1;
        for q = 2:dimConnectedRegions.NumObjects
            if length(dimConnectedRegions.PixelIdxList{q}) > largest
                largest = length(dimConnectedRegions.PixelIdxList{q});
                largestID = q;
            end
        end
        regionMap2(dimConnectedRegions.PixelIdxList{largestID}) = 1;
        backgroundMasksPerY{m} = regionMap2;
                        m = m+1;
        end
        end
    end


%     
    %% This region becomes the background mask
    movieOut = timeByRois;
    backgroundCOMs = zeros(length(backgroundMasksPerY), 2);
    backgroundTrace = zeros(movieSize(3), length(backgroundMasksPerY));
    for k = 1:size(backgroundMasksPerY, 2)
        largestRegionSize = sum(sum(backgroundMasksPerY{k}));
        regionMap = repmat(logical(backgroundMasksPerY{k}),[1 1 movieSize(3)]);
        currentMean = mean(regionMap, 3);
        backgroundCOMs(k, :) = getROICOM(currentMean);
        backgroundRegion = reshape(filteredMovie(regionMap),[largestRegionSize 1 movieSize(3)]);
        backgroundRegion = mean(backgroundRegion);
        thisRoiMask = backgroundMasksPerY{k};
        thisRoiMask = reshape(thisRoiMask,[1 numel(thisRoiMask)]);
        backgroundTrace(:, k) = mean(movieMatrix(:,find(thisRoiMask == 1)),2);
    end
    
    % find which background ROI each ROI is closest to
    distanceSquared = zeros(size(timeByRois, 2), length(backgroundMasksPerY));
    correspondingBackground = [];
    for m = 1:size(distanceSquared, 1)
        for n = 1:length(backgroundMasksPerY)
            distanceSquared(m, n) = sum((ROICOM(m, 1)-backgroundCOMs(n, 1)).^2);
        end
        [c, d] = find(distanceSquared(m, :) == min(distanceSquared(m, :)));
        correspondingBackground(m, 1) = min(d);
    end
    background_intensities = zeros(size(timeByRois, 1), size(timeByRois, 2));
    for i = 1:size(timeByRois, 2)
        background_intensities(:, i) = backgroundTrace(:, correspondingBackground(i));
    end
    
    timeByRois = timeByRois-background_intensities;
    
end