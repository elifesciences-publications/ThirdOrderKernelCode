function movieOut = BackgroundSubtract(movieIn)
    meanMovie = mean(movieIn,3);
    movieSize = size(movieIn);
    
    fractionCutOff = 10;
    %%=================================================================================================
    
    threshold = prctile(reshape(meanMovie,[numel(meanMovie) 1]),fractionCutOff);
    
%     connectedRegions = bwconncomp(meanMovie<threshold);
%     
%     %% Find largest connected dim region
%     largestRegionSize = length(connectedRegions.PixelIdxList{1});
%     largestID = 1;
%     for cc = 2:connectedRegions.NumObjects
%         if length(connectedRegions.PixelIdxList{cc}) > largestRegionSize
%             largestRegionSize = length(connectedRegions.PixelIdxList{cc});
%             largestID = cc;
%         end
%     end
%     
%     %% This region becomes the background mask
%     regionMap = false(movieSize(1),movieSize(2));
%     regionMap(connectedRegions.PixelIdxList{largestID}) = true;
    regionMap = meanMovie<threshold;
    
    % pick the largest continuous region
    a = meanMovie < threshold;
%     b = bwlabel(a);
%     stats = regionprops(b, 'Area');
%     areas = [stats.Area];
%     maxLoc = find(areas ==  max(areas));
%     newRegionMap = zeros(size(regionMap, 1), size(regionMap, 2));
%     newRegionMap(find(b == 4)) = 1;
%     regionMap = logical(newRegionMap);
    largestRegionSize = sum(sum(regionMap));
    regionMap = repmat(regionMap,[1 1 movieSize(3)]);
    
    % extract background region throughout movie
    backgroundRegion = reshape(movieIn(regionMap),[largestRegionSize 1 movieSize(3)]);
    backgroundRegion = mean(backgroundRegion);
%     backgroundRegion = backgroundRegion-min(backgroundRegion);
    
%     filterStd = 7.5;
%     numStd = 3;
%     backgroundFilter = normpdf(-numStd*filterStd:numStd*filterStd,0,filterStd);
%     backgroundFilter = backgroundFilter/sum(backgroundFilter);
%     backgroundFilter = reshape(backgroundFilter,[1 1 numStd*filterStd*2+1]);
%     
%     filteredBackground = imfilter(backgroundRegion,backgroundFilter,'symmetric');
%     filteredBackground = backgroundRegion;
    
    movieOut = bsxfun(@minus,movieIn,backgroundRegion);

    movieOut(movieOut<0) = 0;
end