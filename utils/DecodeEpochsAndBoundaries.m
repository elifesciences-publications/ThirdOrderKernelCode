function [epochNumber, epochBoundaryInds] = DecodeEpochsAndBoundaries(recordedTriggerBeginningIndexes, expectedTriggerBeginningIndexes, expectedEpochs)
% [epoch_number, epoch_boundary_inds] = DecodeEpochsAndBoundaries(recordedTriggerBeginningIndexes, expectedTriggerBeginningIndexes, expectedEpochs)
%
% This function (for the two photon system!) takes in recorded triggers and
% expected triggers--which is specifically the times that the PD should
% have registered a rise and when it actually did rise--and matches them up
% along with the stimulus data epochs to create boundary inds from the
% recorded trigger indexes.

newEpochIndex = 1;
indexInd = 1;
epochNumber = [];
while indexInd <= length(expectedTriggerBeginningIndexes)
    frameIndex = expectedTriggerBeginningIndexes(indexInd);
    % Check if we're at an epoch changeover or if this is just a trigger in
    % the middle. We check from frameIndex-1:frameIndex+1 because of the
    % potential for a stimfunction intrinsic flash to occur right before
    % the epoch code, thus causing the trigger to occur one frame before it
    % actually is present in the expectedEpochs field.
    if isempty(epochNumber) || any(expectedEpochs(frameIndex-1:frameIndex+1)~=epochNumber(newEpochIndex-1, 1))
        if isempty(epochNumber)
            newEpochNumber = expectedEpochs(frameIndex);
        else
            % We're assuming that epochs last at least one frame. Should be
            % right, no?
            newEpochNumber = expectedEpochs(frameIndex+1);
        end
        epochNumber(newEpochIndex, 1) = newEpochNumber;
        epochBoundaryInds(newEpochIndex, 1) = recordedTriggerBeginningIndexes(indexInd);
        if newEpochIndex > 1
            epochBoundaryInds(newEpochIndex-1, 2) = recordedTriggerBeginningIndexes(indexInd);
        end
        newEpochIndex = newEpochIndex + 1;
    end
    indexInd = indexInd + 1;
end
% Check if the last epoch completed (at least with some sort of trigger
% some of the way through) or if it was left hanging. Get rid of it if it
% was left hanging.
if epochBoundaryInds(end, 1) ~= recordedTriggerBeginningIndexes(end)
    epochBoundaryInds(end, 2) = recordedTriggerBeginningIndexes(end);
else
    epochBoundaryInds(end, :) = [];
    epochNumber(end, :) = [];
end


