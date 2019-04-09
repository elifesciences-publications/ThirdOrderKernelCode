function [mask,numMask] = NonFunctionalMask(movie,maskType)
    movieSize = size(movie);
    % know in advance the number of masks so you can apply the proper
    % comprsesive nonlinearity.
    numMask = length(maskType); 
    mask = ones(movieSize(1),movieSize(2));
    
    for mm = 1:length(maskType)
        switch maskType{mm}
            case 'mean'
                mask = mask.*mean(movie,3).^(1/numMask);
            case 'energy'
                meanSubtracted = bsxfun(@minus,movie,mean(movie,3));
                mask = mask.*mean(abs(meanSubtracted),3).^(1/numMask);
        end
    end

    mask = mask/sum(sum(mask));
end