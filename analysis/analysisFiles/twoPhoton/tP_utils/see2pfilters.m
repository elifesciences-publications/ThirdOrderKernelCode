function [ void ] = see2pfilters( filtersOut )
% See all of the second order filters in twoPhoton's filtersOut structure.

    nMultiBars = size(filtersOut,1);
    nROIs = size(filtersOut,2);
    maxTau = round(sqrt(length(filtersOut{1})));
    
    % show filter for each bar pair
    for r = 1:nMultiBars
        figure;
        for q = 1:nROIs
            spCols = ceil(nROIs/3);
            subplot(spCols,3,q);
            imagesc(reshape(filtersOut{r,q},[maxTau maxTau])); 
            thisTitle = sprintf('ROI %i, bar pair %i',q,r);
            title(thisTitle);
        end
    end
    
    % show mean for each bar pair
    figure;
    for r = 1:nMultiBars
        subplot(nMultiBars,1,r);
        meanFilters{r} = zeros([maxTau maxTau]);
        for q = 1:nROIs
            meanFilters{r} = meanFilters{r} + reshape(filtersOut{r,q},[maxTau maxTau]) / nROIs;
        end
        imagesc(meanFilters{r});
        thisTitle = sprintf('Mean filter, bar pair %i',r);
        title(thisTitle);
    end
    
    % show mean across bar pairs
    figure;
    allMean = zeros([maxTau maxTau]);
    for r = 1:nMultiBars
        allMean = allMean + meanFilters{r} / nMultiBars;
    end
    imagesc(allMean);
    title('All filters, all bar pairs');
    
    void = 0;
    
end

