function [  upperInds, lowerInds ] = differentialEpochIndices(trigger_inds, differentialEpochs, normSize, see)
% Hijacking part of triggeredResponseDifferentialROIDetection to return 
% indices of differential epochs 

    epochs = fields(trigger_inds);
    epoch_nums = cellfun(@(epoch) str2num(epoch(epoch>='0' & epoch<='9')), epochs);

    if nargin < 4
        see = 0;
    end
    
    for diffEpochInd = size(differentialEpochs, 2):-1:1
        if ~any(epoch_nums==differentialEpochs(1, diffEpochInd))
            warning(['Epoch ' num2str(differentialEpochs(1, diffEpochInd)) ' not found in the photodiode data']);
            differentialImages(:, :, diffEpochInd) = [];
            continue;
        end
        if ~any(epoch_nums==differentialEpochs(2, diffEpochInd))
            warning(['Epoch ' num2str(differentialEpochs(2, diffEpochInd)) ' not found in the photodiode data']);
            differentialImages(:, :, diffEpochInd) = [];
            continue;
        end
        epochBase = differentialEpochs(1, diffEpochInd);
        epochOpposite = differentialEpochs(2, diffEpochInd);
        boundsBase = trigger_inds.(['epoch_' num2str(epochBase)]).bounds;
        boundsOpposite = trigger_inds.(['epoch_' num2str(epochOpposite)]).bounds;

        % Take ceil and floor because the full image won't see the stimulus
        % until after the frame that got the PD signal and it will have lost
        % the stimulus right before the frame that got the PD signal
      
    epochs = fields(trigger_inds);
    epoch_nums = cellfun(@(epoch) str2num(epoch(epoch>='0' & epoch<='9')), epochs);

    for diffEpochInd = size(differentialEpochs, 2):-1:1
        if ~any(epoch_nums==differentialEpochs(1, diffEpochInd))
            warning(['Epoch ' num2str(differentialEpochs(1, diffEpochInd)) ' not found in the photodiode data']);
            differentialImages(:, :, diffEpochInd) = [];
            continue;
        end
        if ~any(epoch_nums==differentialEpochs(2, diffEpochInd))
            warning(['Epoch ' num2str(differentialEpochs(2, diffEpochInd)) ' not found in the photodiode data']);
            differentialImages(:, :, diffEpochInd) = [];
            continue;
        end
        epochBase = differentialEpochs(1, diffEpochInd);
        epochOpposite = differentialEpochs(2, diffEpochInd);
        boundsBase = trigger_inds.(['epoch_' num2str(epochBase)]).bounds/normSize;
        boundsOpposite = trigger_inds.(['epoch_' num2str(epochOpposite)]).bounds/normSize;

        % Take ceil and floor because the full image won't see the stimulus
        % until after the frame that got the PD signal and it will have lost
        % the stimulus right before the frame that got the PD signal
        finalBoundsBase = zeros(size(boundsBase));
        finalBoundsBase(1, :) = ceil(boundsBase(1, :));
        finalBoundsBase(2, :) = floor(boundsBase(2, :));
        finalBoundsOpposite = zeros(size(boundsOpposite));
        finalBoundsOpposite(1, :) = ceil(boundsOpposite(1, :));
        finalBoundsOpposite(2, :) = floor(boundsOpposite(2, :));

        % Works because we'll take all the indexes between the top row values
        % and the bottom row values; add one for each column because
        % subtraction isn't inclusive of both bounds
        indexesBase = zeros(sum(diff(finalBoundsBase))+size(finalBoundsBase, 2), 1);
        lowerInds{diffEpochInd} = zeros(sum(diff(finalBoundsOpposite))+size(finalBoundsOpposite, 2), 1);

        % Loop through to create the base indexes
        indexInd = 1;
        for boundsBaseLoop = finalBoundsBase
            bounds = boundsBaseLoop(1):boundsBaseLoop(2);
            indexesBase(indexInd:indexInd+length(bounds)-1) = bounds;
            indexInd = indexInd + length(bounds);
        end

        % Loop through to create the opposite indexes
        indexInd = 1;
        for boundsOppositeLoop = finalBoundsOpposite
            bounds = boundsOppositeLoop(1):boundsOppositeLoop(2);
            lowerInds{diffEpochInd}(indexInd:indexInd+length(bounds)-1) = bounds;
            indexInd = indexInd + length(bounds);
        end
        upperInds{diffEpochInd} = indexesBase;
    end
        finalBoundsBase = zeros(size(boundsBase));
        finalBoundsBase(1, :) = ceil(boundsBase(1, :));
        finalBoundsBase(2, :) = floor(boundsBase(2, :));
        finalBoundsOpposite = zeros(size(boundsOpposite));
        finalBoundsOpposite(1, :) = ceil(boundsOpposite(1, :));
        finalBoundsOpposite(2, :) = floor(boundsOpposite(2, :));

        % Works because we'll take all the indexes between the top row values
        % and the bottom row values; add one for each column because
        % subtraction isn't inclusive of both bounds
        indexesBase = zeros(sum(diff(finalBoundsBase))+size(finalBoundsBase, 2), 1);
        lowerInds{diffEpochInd} = zeros(sum(diff(finalBoundsOpposite))+size(finalBoundsOpposite, 2), 1);

        % Loop through to create the base indexes
        indexInd = 1;
        for boundsBaseLoop = finalBoundsBase
            bounds = boundsBaseLoop(1):boundsBaseLoop(2);
            indexesBase(indexInd:indexInd+length(bounds)-1) = bounds;
            indexInd = indexInd + length(bounds);
        end

        % Loop through to create the opposite indexes
        indexInd = 1;
        for boundsOppositeLoop = finalBoundsOpposite
            bounds = boundsOppositeLoop(1):boundsOppositeLoop(2);
            lowerInds{diffEpochInd}(indexInd:indexInd+length(bounds)-1) = bounds;
            indexInd = indexInd + length(bounds);
        end
        upperInds{diffEpochInd} = indexesBase;
    end
    
    if see
        plotVect = zeros(max(lowerInds{size(differentialEpochs,2)})-(min(upperInds{1})-1), ...
            size(differentialEpochs,2));
        for q = 1:size(differentialEpochs,2);     
            for r = 1:length(lowerInds{q})
                plotVect(lowerInds{q}-(min(upperInds{1})-1),q) = 1;
            end 
        end
        figure; plot(plotVect);
    end
    
end

