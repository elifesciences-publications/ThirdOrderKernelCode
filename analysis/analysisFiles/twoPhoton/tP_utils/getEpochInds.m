function inds = getEpochInds( Z, controlName )
% Given the name of an epoch, outputs cell array containing all chunks of
% that epoch. You must have already run Z.stimulus.

    loadFlexibleInputs(Z)
    
    %% Convert name to number
    if isnumeric(controlName)
        epochNum = controlName;
    else
        if isfield(Z,'stimulus')
            if isfield(Z.stimulus,'params')
                epochNum = find(strcmp({Z.stimulus.params.epochName}, controlName));
            else
                epochNum = controlName;
            end
        else
            epochNum = controlName;
        end
    end
    
%     epochNum = epochNum(end);
    %% Get index bounds
    for epochNumInd = 1:length(epochNum)
        bounds = trigger_inds.(['epoch_' num2str(epochNum(epochNumInd))]).bounds;
        finalBounds = zeros(size(bounds));
        finalBounds(1, :) = ceil(bounds(1, :));
        finalBounds(2, :) = floor(bounds(2, :));
        indices = zeros(sum(diff(finalBounds))+size(finalBounds,2), 1);
        indexInd = 1;
        for boundsLoop = finalBounds
            theseBounds = boundsLoop(1):boundsLoop(2);
            indices(indexInd:indexInd+length(theseBounds)-1) = theseBounds;
            indexInd = indexInd + length(theseBounds);
        end
        
        % Cut up into discontinuous chunks
        blockEnds = find(diff(indices) > 1);
        blockStarts = [ 1; blockEnds+1 ];
        blockEnds = [ blockEnds; length(indices) ];
        for q = 1:length(blockEnds)
            inds{epochNumInd, q} = indices(blockStarts(q):blockEnds(q));
        end
    end
    
end

