function analysis = GetProcessedFilteredTrials(flyResp,epochs,params,varargin)
    normWalkDuration = 30; % number of frames in the interleave before the epoch to normalize walking to
    normWalkShift = -30;
    epsilon = 0.001; % when normalizing walking, may want to add epsilon to the denominator to avoid errors
    snipShift = 6; % biological delay in frames ~80-100ms
    analysis = cell(0,1);
    removeNonResponsive = 1;
    duration = [];
    
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    %% This file will
    % GetSnips
    % NormalizeWalking
    % MeanSubtractTurns
    % FilterTrials
    
    %% get snips of time over duration of epoch
    % find the index at which each epoch starts
    epochStartTimes = GetStartTimes(epochs);
    
    if isempty(duration)
        epochDurations = [params.duration];
    else
        epochDurations = zeros(size(params))+duration;
    end
    
    maxRange = [min([snipShift normWalkShift]) max(max(snipShift+epochDurations))];
    
    % get rid of start times and are too early and end times that are too late
    filteredStartTimes = FilterStartTimes(epochStartTimes,epochDurations,maxRange,size(epochs,1));
    
    % shift all start times by a set amount to account for behavioral delay
    shiftedEpochStartTimes = ShiftStartTimes(filteredStartTimes,snipShift);
    % get the snips from the matrix and put them in a snip mat of the
    % format {epochs, flies}[time trials]
    snipMat = GetSnips(flyResp,shiftedEpochStartTimes,epochDurations);
    
    % write to output structure
    analysis{end+1}.name = 'snipMat';
    analysis{end}.snipMat = snipMat;
    analysis{end}.shiftedEpochStartTimes = shiftedEpochStartTimes;
    analysis{end}.epochDurations = epochDurations;
    
    %% normalize walking
    % get the start times for the snip during interleave to normalize walking by
    normWalkStartTimes = ShiftStartTimes(filteredStartTimes,normWalkShift);
    % get the duration of the snip during interleave to normalize walking by
    normWalkDurations = normWalkDuration*ones(size(epochDurations));
    % get the snip during interleave to normalize walking by
    walkRespDuringInterleave = GetSnips(flyResp,normWalkStartTimes,normWalkDurations);
    % average the snip during interleave to normalize walking by
    beforeEpochAve = ReduceDimension(walkRespDuringInterleave,{'time' 'trials'});
    
    % normalize walking
    normalizedWalking = NormalizeWalking(snipMat,beforeEpochAve,epsilon);
    
    % write to output structure
    analysis{end+1}.name = 'normalizedWalking';
    analysis{end}.snipMat = normalizedWalking;
    analysis{end}.normWalkStartTimes = normWalkStartTimes;
    analysis{end}.normWalkDurations = normWalkDuration;
    analysis{end}.walkRespDuringInterleave = walkRespDuringInterleave;
    
    %% mean subtract turns
    % get mean of time trace and subtract from turns
    turnMeans = mean(flyResp(:,:,1),1);
    meanSubtracted = MeanSubtractTurns(normalizedWalking,turnMeans);

    % write to output structure
    analysis{end+1}.name = 'meanSubtracted';
    analysis{end}.snipMat = meanSubtracted;
    analysis{end}.turnMeans = turnMeans;
    
    %% remove trials in which the fly does not behave
    if removeNonResponsive
        selectedTrials = GetResponsiveTrials(snipMat);
        filteredTrials = FilterTrials(meanSubtracted,selectedTrials);
    else
        selectedTrials = 'all';
        filteredTrials = meanSubtracted;
    end
    
    % write to output structure
    analysis{end+1}.name = 'filteredTrials';
    analysis{end}.snipMat = filteredTrials;
    analysis{end}.selectedTrials = selectedTrials;
end