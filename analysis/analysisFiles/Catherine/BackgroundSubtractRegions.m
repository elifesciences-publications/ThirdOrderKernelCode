function movieOut = BackgroundSubtractRegions(movieIn)
    meanMovie = mean(movieIn,3);
    movieSize = size(movieIn);
    
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
     kRange = m-1;
%     
    %% This region becomes the background mask
    movieOut = movieIn;
    m = 1;
    for k = 1:size(backgroundMasksPerY, 2)
        largestRegionSize = sum(sum(backgroundMasksPerY{k}));
        regionMap = repmat(logical(backgroundMasksPerY{k}),[1 1 movieSize(3)]);
    
        backgroundRegion = reshape(movieIn(regionMap),[largestRegionSize 1 movieSize(3)]);
        backgroundRegion = mean(backgroundRegion);
    
        movieOut(m:m+9, :, :) = bsxfun(@minus,movieIn(m:m+9, :, :),backgroundRegion);
%         [rowIndices colIndices] = find(backgroundMasksPerY{k} == 1);
%         backgroundTrace = squeeze(mean(mean(movieIn(rowIndices, colIndices, :))));
%         movieOut(k:k+9, :, :) = movieIn(k:k+9, :, :) - repmat(backgroundTrace', 10, 1);
        m = m+10;
    end
    %movieOut = bsxfun(@minus,movieIn,backgroundRegion);

    movieOut(movieOut<0) = 0;
end