function outputSnipMat = SubtractInterleaveFromTurning(inputSnipMat,interleaveMean)
    % Takes in a response snipMat and a snipMat with the average value of
    % the preceding interleave and subtracts it off

    outputSnipMat = cell(size(inputSnipMat));
    
    [numEpochs,numRoi] = size(inputSnipMat);
    for epoch = 1:numEpochs
        for roi = 1:numRoi
            if size(inputSnipMat{epoch,roi},3) == 2
                % don't mean subtract walking, if it exists so just give
                % zeros for the mean
                interleaveMean{epoch,roi}(:,:,2) = 0;
            end
            
            means = interleaveMean{epoch,roi};
            
            outputSnipMat{epoch,roi} = bsxfun(@minus,inputSnipMat{epoch,roi},means);
        end
    end
end