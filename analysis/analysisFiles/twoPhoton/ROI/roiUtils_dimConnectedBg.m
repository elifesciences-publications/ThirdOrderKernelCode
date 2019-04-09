function bkgdMask = roiUtils_dimConnectedBg( Z )
% Automatically selects a dim connected region to use as a background.

    dimThreshLevel = .05;
    loadFlexibleInputs(Z); 
        % Grab movie
    inMovie = Z.grab.imgFrames;
    % Delete imgFrames; save movie average
    Z.rawTraces.movieMean = mean(Z.grab.imgFrames,3);
    Z.grab = rmfield(Z.grab,'imgFrames');
    
    
    %% First, pick background ROI so that we can exclude this area later
    if ~isfield(Z, 'rawTraces')
        meanImg = mean(Z.grab.imgFrames,3);
    else
        meanImg = Z.rawTraces.movieMean;
    end
    
    meanImg(find(~Z.grab.windowMask)) = 200;
    dimThresh = percentileThresh(meanImg,dimThreshLevel);
    dimPixels = meanImg < dimThresh; 
    dimConnectedRegions = bwconncomp(dimPixels);
    
    %% Find largest connected dim region
    regionMap = zeros(imgSize(1),imgSize(2));
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
    
    %% This region becomes the background mask
    bkgdMask = regionMap;

end

