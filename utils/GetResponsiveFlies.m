function responsive = GetResponsiveFlies(resp)

    absCutOffWalk = 2; % mm/sec
    absCutOffTurn = 60; % deg/sec
    relCutOffTurn = 1; % std/turn

    % flies that don't have a high enough std
    fliesHighTurnSTD = std(resp(:,:,1),[],1)>absCutOffTurn;
    
    % flies that don't walk fast enough
    fliesHighWalk = mean(resp(:,:,2),1)>absCutOffWalk;

    % don't have a high enough std to mean ratio
    fliesHighSTDtoMean = std(resp(:,:,1),[],1)./abs(mean(resp(:,:,1),1))>relCutOffTurn;
    
    responsive = logical(fliesHighTurnSTD & fliesHighWalk & fliesHighSTDtoMean);
end