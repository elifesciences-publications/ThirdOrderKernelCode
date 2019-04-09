function output = GetResponsiveTrials(snipMat)
% Takes in a response snipMat and outputs a cell array with vectors of 1's
% and 0's corresponding to trials where the fly was responding.

    [numEpochs,numFlies] = size(snipMat);
    for epoch = 1:numEpochs
        for fly = 1:numFlies
            singleEpochMat = snipMat{epoch,fly};
            turnCutoff = 1;
            walkCutoff = 0.1;

            fractionSpentTurning = mean(abs(singleEpochMat(:,:,1)) > turnCutoff);
            fractionSpentWalking = mean(abs(singleEpochMat(:,:,2)) > walkCutoff);

            fracTurnCutoff = 0.3;
            fracWalkCutoff = 0.3;

            responsiveTrials = (fractionSpentTurning > fracTurnCutoff) & ...
                               (fractionSpentWalking > fracWalkCutoff);
                           
            output{epoch,fly} = responsiveTrials;
        end
    end
end