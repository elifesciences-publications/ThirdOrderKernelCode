function output = NormalizeWalking(inputSnipMat,normValues,epsilon)
    % Takes in a response snipMat and a snipMat with time and trials
    % averaged. Output is a snipMat normalized by the averaged values.
    % Optional epsilon can be provided to avoid dividing by 0.
    
    if (nargin < 3)
        epsilon = 0;
    end
    
    output = cell(size(inputSnipMat));
    
    [numEpochs,numFlies] = size(inputSnipMat);
    for epoch = 1:numEpochs
        for fly = 1:numFlies
            thisResponse = inputSnipMat{epoch,fly};
            [numFrames, numTrials,~] = size(thisResponse); 
            thisNormValues = repmat(normValues{1,fly}(1,1,2),[numFrames numTrials]);
            output{epoch,fly}(:,:,1) = thisResponse(:,:,1);
            output{epoch,fly}(:,:,2) = thisResponse(:,:,2)./(thisNormValues+epsilon);
        end
    end
end