function responsive = GetResponsiveFlies(resp,epochs)

    absCutOffWalk = 1; % mm/sec
    absCutOffTurn = 40; % deg/sec
    relCutOffTurn = 1.5; % std/turn
    
    numFlies = size(epochs,2);
    interelaveEpoch = epochs==1;
    interleaveEpochInd = find(diff([zeros(1,numFlies); interelaveEpoch])==-1);
    
    [row,col] = ind2sub(size(epochs),interleaveEpochInd);
    walkingMean = zeros(1,numFlies);
    turningMean = zeros(1,numFlies);
    turningStd = zeros(1,numFlies);
    numTrials = zeros(1,numFlies);

    % duration to average over in frames;
    interleaveAverageDuration = min([60 row(1)]);
    
    for ii = 1:length(col)
        walkingMean(1,col(ii)) = walkingMean(1,col(ii))+mean(resp((row(ii)-interleaveAverageDuration+1):row(ii),col(ii),2));
        turningMean(1,col(ii)) = turningMean(1,col(ii))+mean(resp((row(ii)-interleaveAverageDuration+1):row(ii),col(ii),1));
        turningStd(1,col(ii)) = turningStd(1,col(ii))+std(resp((row(ii)-interleaveAverageDuration+1):row(ii),col(ii),1));
        numTrials(1,col(ii)) = numTrials(1,col(ii)) + 1;
    end
    
    walkingMean = walkingMean./numTrials;
    turningMean = turningMean./numTrials;
    turningStd = turningStd./numTrials;
    
    % flies that don't have a high enough std
    fliesHighTurnSTD = turningStd>absCutOffTurn;
    
    % flies that don't walk fast enough
    fliesHighWalk = walkingMean>absCutOffWalk;

    % don't have a high enough std to mean ratio
    fliesHighSTDtoMean = turningStd./abs(turningMean)>relCutOffTurn;
    
    responsive = logical(fliesHighTurnSTD & fliesHighWalk & fliesHighSTDtoMean);
end