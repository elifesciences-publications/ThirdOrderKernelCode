function stimulusParams = MergeParameterFiles(probeParams, stimulusParams)

probeFields = fields(probeParams);
stimFields = fields(stimulusParams);
% Note that totalTime should be in p{ff} no matter what according
% to the totalTime if statement above<-there is no if statement above >.>
probeDuration = probeParams(1).totalTime;
stimDuration = stimulusParams(1).totalTime;

for probeField = probeFields'
    if ~any(strcmp(stimFields, probeField))
        stimulusParams(1).(probeField{1}) = '';
    end
end

for stimField = stimFields'
    if ~any(strcmp(probeFields, stimField))
        probeParams(1).(stimField{1}) = '';
    end
end

stimulusParams = [probeParams stimulusParams];
stimulusParams(1).totalTime = probeDuration + stimDuration;
stimulusParams(end).nextEpoch = length(probeParams)+1;