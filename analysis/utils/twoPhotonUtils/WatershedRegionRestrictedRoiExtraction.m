function [timeByRois,watershededMean,extraVars] = WatershedRegionRestrictedRoiExtraction(filteredMovie,deltaFOverF,~,~,~,varargin)
    %% Defaults
    fgThresh = .75;
    wiThresh = .75;
    minPixNum = 20;
    cutWithinROI = true;
    threshWithinROI = .5;
  
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
    if isempty(filteredMovie)
        timeByRois = zeros(size(filteredMovie,3),0);
        watershededMean = zeros(size(filteredMovie, 1), size(filteredMovie, 2));
        return;
    end
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
        
    
    
    % manually select any ROIs that are part of the structure
    [ROICOM, roiMasks] = getROICOM(watershededMean);
    fprintf('Draw polygon around the ROIs to be kept. Double-click when done.');
    tp_plotROIs_v2(filteredMovie, roiMasks, ROICOM);
    %[x,y] = ginput;
    [~,poly_y,poly_x]=roipoly;
    inPoly= inpolygon(ROICOM(:,1),ROICOM(:,2),poly_x,poly_y);
    ROIsToExclude=find(~inPoly);
    
    % determine which ROIs are inside the polygon
    %distanceSquared = zeros(length(x), numRois);
    %ROIsFound = zeros(length(x), 1);

   %ROIsFound=
    
    for k = 1:length(ROIsToExclude)
        watershededMean(watershededMean == ROIsToExclude(k)) = 0;
    end
   % roiNums = unique(watershededMean(2:end));
    
   
    numRois = length(unique(watershededMean))-1;
    roiNums = unique(watershededMean);
    roiNums = roiNums(2:end);

    for k = 1:numRois
        watershededMean(watershededMean == roiNums(k)) = k;
    end
    
   [ROICOM, roiMasks] = getROICOM(watershededMean);
   tp_plotROIs_v2(filteredMovie, roiMasks, ROICOM)

    
    timeByRois = zeros(size(filteredMovie,3),numRois);
    for rr = 1:numRois
        thisRoiMask = watershededMean == rr;
        thisRoiMask = reshape(thisRoiMask,[1 numel(thisRoiMask)]);
        timeByRois(:,rr) = mean(movieMatrix(:,thisRoiMask),2);
    end
    
end