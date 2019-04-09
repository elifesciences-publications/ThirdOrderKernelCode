function strongShedsMask = watershedCluster( Z )
% Selects regions of interest by (1) watershedding the differential movie,
% and (2) clustering watershed regions by their time traces. 
%   Inputs
%       Z: all previous work of twoPhotonMaster
%       inMovie: the movie to cluster, ht x wd x frames
%   Outputs:
%       clusterMasks: ht x wd x nClusters array of clutsered regions
%       strongShedsMasks: binary masks corresponding to each ROI
%       clusterIDs: cluster index of each mask in strongShedsMasks
%
%   Steps:
%       1. Watershedding is done on -meanImg, the identity of which depends 
%          on grabRoi. ! ! We make meanImg negative because we want to cut
%          around BRIGHT SPOTS IN THE MOVIE, so to make these basins we
%          have to flip the sign of the image. ! ! Unsharp masking of
%          meanImg removes local variation and pulls out more regions of
%          interest.
%       2. We calculate the average value of meanImg within each
%          watershed region and keep only the fgThresh % most active.
%          Within each of these retained regions, we compute the wiThresh
%          percentile for that region and keep only the pixels above that
%          value.
%       3. We choose the dimmest bgThresh of pixels in inMovie at the
%          background. We exclude pixels that are exactly zero because
%          these are probably just cut off by the earlier trapezoid-drawing
%          step, not actual dim pixels in the movie. The dimmest 10% is
%          calculated from the average of inMovie and NOT from activityImg.
%          If there is any overlap between the dimmest pixels in inMovie
%          and the most responsive regions, give the pixel to the
%          foreground rois.
%       4. The background mask is concatenated as the last mask in
%          strongShedsMask - from now on, the background will be treated
%          like the last watershed region.


    %% Defaults
    fgThresh = .75;
    wiThresh = .75;
    minPixNum = 0;
    cutWithinROI = true;
    threshWithinROI = .5;
  
    loadFlexibleInputs(Z)
    
    %% Background selection - dim connected region
    bkgdMask = roiUtils_dimConnectedBg( Z );
    % Update the windowMask so that background regions are excluded from
    % all future selection. 
    Z.grab.windowMask = Z.grab.windowMask .* ~bkgdMask;
    
    %% Watershedding
    filledIn = roiUtils_watershedMovieAvg( Z, fgThresh );
    
    %% Compute the brightest pixels within each ROI
    meanImg = mean(Z.grab.imgFrames,3) .* Z.grab.windowMask;
    meanImgRestrict = meanImg(:);
    meanImgRestrict = meanImgRestrict(find(meanImgRestrict ~= 0));
    fgThreshVal = percentileThresh( meanImgRestrict, fgThresh );
    fgThreshMask = double( meanImg >= fgThreshVal );
    fgThreshMask = fgThreshMask .* Z.grab.windowMask;
    for q = 1:max(filledIn(:))
        % Pick out the mask for this watershed, dot into meanImg
        % Restrict away zero values so that percentile can be accurately
        % calculated
        thisShed = double( filledIn == q );
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
    nSheds = size(strongShedsMask,3);
    % Make background last mask
    strongShedsMask = cat(3,strongShedsMask,bkgdMask);

end

