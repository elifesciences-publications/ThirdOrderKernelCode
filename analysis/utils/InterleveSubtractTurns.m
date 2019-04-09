function output = InterleveSubtractTurns(inputSnipMat,aveInterleveValues)
    % Takes in a response snipMat and a snipMat with time and trials
    % averaged. Output is a snipMat minus the averaged values intereleve.
    
    output = cell(size(inputSnipMat));
    
    [numEpochs,numFlies] = size(inputSnipMat);
    for epoch = 1:numEpochs
        for fly = 1:numFlies
            thisResponse = inputSnipMat{epoch,fly};
            [numFrames, numTrials,~] = size(thisResponse); 
            thisAveValues = repmat(aveInterleveValues{epoch,fly}(1,1,1),[numFrames numTrials]);
            output{epoch,fly}(:,:,2) = thisResponse(:,:,2);
            output{epoch,fly}(:,:,1) = thisResponse(:,:,1) - thisAveValues;
        end
    end
end