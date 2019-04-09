function Z = tp_spatialFocusShedwise( Z )
% Determines which bar pair a given ROI is most responsive to by the R2
% coefficient with that stimulus. Needs to be run after linear kernel
% extraction.
    
    nMultiBars = 4;   
    loadFlexibleInputs
    
    keyboard
    
    guessFilter = [zeros(1,10) ones(1,30)];
    
    for q = 1:nMultiBars
        for r = 1:size(Z.ROI.shedIDs,2)
            actualTrace = Z.kernels.alignedStimulusData{q}(:,r);
            actualVar = actualTrace*actualTrace';
            predTrace = filter(guessFilter,sum(guessFilter),actualTrace);
            R(q,r) = actualTrace*predTrace'/actualVar;
        end
    end
    keyboard
    
%     for q = 1:4 % over directions
%         getDiffEp = Z.diffEp.differentialImages(:,:,q);
%         [ N, centers ] = hist(getDiffEp(:),100);
%         percentiles = cumsum(N) / sum(N);
%         threshInd = find(percentiles > .9, 1);
%         dsThresh = centers(threshInd);
%         dsMask(:,:,q) = ( getDiffEp > dsThresh ) .* Z.ROI.windowMask;
%     end
%     
%     guessFilter = [zeros(1,10) zeros(1,30) zeros(1,20)];
%     for q = 1:nMultiBars
%         
%     end
    
    end

