function Z = tp_spatialFocus( Z )
% Determines which bar pair a given area is most responsive to by the R2
% coefficient with that stimulus. A lazy way to do this would be the angle
% between the extracted filter and a filter representing what I would guess
% the response looks like, but this fails to take into account varying
% noise levels--cleaner to do it from scratch (or maybe to do both)?
    
    for q = 1:4 % over directions
        getDiffEp = Z.diffEp.differentialImages(:,:,q);
        [ N, centers ] = hist(getDiffEp(:),100);
        percentiles = cumsum(N) / sum(N);
        threshInd = find(percentiles > .9, 1);
        dsThresh = centers(threshInd);
        dsMask(:,:,q) = ( getDiffEp > dsThresh ) .* Z.ROI.windowMask;
    end
    keyboard
    
    guessFilter = [zeros(1,10) zeros(1,30) zeros(1,20)];
    for q = 1:nMultiBars
        
    end
    
end

