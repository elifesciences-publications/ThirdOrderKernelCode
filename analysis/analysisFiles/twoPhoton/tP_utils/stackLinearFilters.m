function [ void ] = stackLinearFilters( filters )
% Plots "stack" of linear filters to the same bar pair, and all overlaid,
% and the average to a given bar pair, and the average to all bar pairs
% overlaid.
    
    nMultiBars = size(filters,1);
    nROIs = size(filters,2);
    
    % show stack for each bar pair
    for r = 1:nMultiBars
        catFilters{r} = [];
        for q = 1:nROIs
            catFilters{r} = cat(2,catFilters{r},filters{r,q});
        end
        figure; 
        plot(catFilters{r}); 
        thisTitle = sprintf('All filters, bar pair %i',r);
        title(thisTitle);
    end
    
    % show all bar pairs overlaid
    for r = 1:nMultiBars
        catCatFilters = [];
        catCatFilters = cat(2,catCatFilters,catFilters{r});
    end
    figure; 
    plot(catCatFilters);
    title('All filters, all bar pairs');
    
    % show mean for each bar pair
    figure;
    for r = 1:nMultiBars
        subplot(nMultiBars,1,r); 
        meanFilters{r} = mean(catFilters{r},2);
        plot(meanFilters{r});
        thisTitle = sprintf('Mean filter, bar pair %i',r);
        title(thisTitle);
    end
    
    % show mean for all bar pairs
    figure;
    allVect = zeros(size(catFilters{1},1),1);
    for r = 1:nMultiBars
        allVect = allVect + meanFilters{r}/nMultiBars;
    end
    plot(allVect);
    title('All filters, all bar pairs');
    keyboard
    
    void = 0;

end

